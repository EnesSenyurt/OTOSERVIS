

import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../lib/db';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import type { RowDataPacket } from 'mysql2';
dotenv.config();

function verifyAdmin(req: NextApiRequest, res: NextApiResponse): boolean {
  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) {
    res.status(401).json({ message: 'Unauthorized' });
    return false;
  }
  try {
    const payload = jwt.verify(auth.split(' ')[1], process.env.JWT_SECRET!);
    if ((payload as any).role !== 'admin') {
      res.status(403).json({ message: 'Forbidden' });
      return false;
    }
    return true;
  } catch {
    res.status(401).json({ message: 'Invalid token' });
    return false;
  }
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  
  if (req.method === 'GET') {
    const [rows] = await pool.query<RowDataPacket[]>(
      `SELECT id, part_name, part_code, cost, stock
       FROM vehicle_parts
       ORDER BY part_name`
    );
    return res.status(200).json(rows);
  }

  
  if (req.method === 'POST') {
    if (!verifyAdmin(req, res)) return;

    const { part_name, part_code, cost, stock } = req.body;
    
    if (!part_name || !part_code || cost == null || stock == null) {
      return res.status(400).json({
        message: 'part_name, part_code, cost ve stock zorunlu',
      });
    }

    try {
      const [result] = await pool.query(
        `INSERT INTO vehicle_parts (part_name, part_code, cost, stock)
         VALUES (?, ?, ?, ?)`,
        [part_name, part_code, cost, stock]
      );
      const insertId = (result as any).insertId;
      return res.status(201).json({
        id: insertId,
        part_name,
        part_code,
        cost,
        stock,
      });
    } catch (err: any) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'Bu kod zaten mevcut' });
      }
      console.error(err);
      return res.status(500).json({ message: 'Server error' });
    }
  }

  
  if (req.method === 'DELETE') {
    if (!verifyAdmin(req, res)) return;

    const id = parseInt(req.query.id as string, 10);
    if (isNaN(id)) {
      return res.status(400).json({ message: 'Geçersiz id' });
    }
    await pool.query(`DELETE FROM vehicle_parts WHERE id = ?`, [id]);
    return res.status(204).end();
  }

  
  return res.status(405).end();
}
