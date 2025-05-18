import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../../lib/db';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import type { RowDataPacket } from 'mysql2';
dotenv.config();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  
  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) return res.status(401).json({ message: 'Unauthorized' });
  let payload: any;
  try { payload = jwt.verify(auth.split(' ')[1], process.env.JWT_SECRET!); }
  catch { return res.status(401).json({ message: 'Invalid token' }); }
  const userId = payload.sub as number;
  const isAdmin = payload.role === 'admin';

  
  if (req.method === 'GET') {
    if (isAdmin) {
      const [rows] = await pool.query<RowDataPacket[]>(
        `SELECT o.id, u.name AS client_name, p.part_name, o.quantity, o.order_date, o.status
         FROM part_orders o
         JOIN users u ON o.user_id = u.id
         JOIN vehicle_parts p ON o.part_id = p.id
         ORDER BY o.order_date DESC`
      );
      return res.status(200).json(rows);
    } else {
      const [rows] = await pool.query<RowDataPacket[]>(
        `SELECT o.id, p.part_name, o.quantity, o.order_date, o.status
         FROM part_orders o
         JOIN vehicle_parts p ON o.part_id = p.id
         WHERE o.user_id = ?
         ORDER BY o.order_date DESC`, [userId]
      );
      return res.status(200).json(rows);
    }
  }

  
  if (req.method === 'POST') {
    const { partId, quantity } = req.body;
    if (partId == null || quantity == null) {
      return res.status(400).json({ message: 'partId ve quantity zorunlu' });
    }
    
    const [pRows] = await pool.query<RowDataPacket[]>(
      `SELECT stock FROM vehicle_parts WHERE id = ?`, [partId]
    );
    if (!pRows.length) return res.status(404).json({ message: 'Parça bulunamadı' });
    if ((pRows[0].stock as number) < quantity) {
      return res.status(400).json({ message: 'Yeterli stok yok' });
    }
    
    await pool.query(
      `INSERT INTO part_orders (user_id, part_id, quantity) VALUES (?, ?, ?)`,
      [userId, partId, quantity]
    );
    await pool.query(
      `UPDATE vehicle_parts SET stock = stock - ? WHERE id = ?`,
      [quantity, partId]
    );
    return res.status(201).json({ message: 'Sipariş alındı' });
  }

  return res.status(405).end();
}
