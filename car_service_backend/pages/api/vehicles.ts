

import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../lib/db';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import type { RowDataPacket, OkPacket } from 'mysql2';
dotenv.config();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  
  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Unauthorized' });
  }
  let userId: number;
  try {
    const payload = jwt.verify(auth.split(' ')[1], process.env.JWT_SECRET!);
    userId = (payload as any).sub as number;
  } catch {
    return res.status(401).json({ message: 'Invalid token' });
  }

  try {
    if (req.method === 'GET') {
      
      const [rows] = await pool.query<RowDataPacket[]>(
        'SELECT id, make, model, plate_number AS plateNumber, year FROM vehicles WHERE owner_id = ?',
        [userId]
      );
      return res.status(200).json(rows);
    }

    if (req.method === 'POST') {
      const { make, model, plateNumber, year } = req.body;
      if (!make || !model || !plateNumber || !year) {
        return res.status(400).json({ message: 'Eksik alan' });
      }
      const [result] = await pool.query<OkPacket>(
        `INSERT INTO vehicles(owner_id, make, model, plate_number, year)
         VALUES (?, ?, ?, ?, ?)`,
        [userId, make, model, plateNumber, year]
      );
      return res.status(201).json({
        id: result.insertId,
        make,
        model,
        plateNumber,
        year
      });
    }

    return res.status(405).end();
  } catch (err) {
    console.error('Vehicles handler error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
}
