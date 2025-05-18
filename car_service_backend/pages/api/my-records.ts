

import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../lib/db';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import type { RowDataPacket } from 'mysql2';
dotenv.config();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') return res.status(405).end();

  
  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) return res.status(401).json({ message: 'Unauthorized' });
  let userId: number;
  try {
    const payload = jwt.verify(auth.split(' ')[1], process.env.JWT_SECRET!);
    userId = (payload as any).sub as number;
  } catch {
    return res.status(401).json({ message: 'Invalid token' });
  }

  try {
    
    const [rows] = await pool.query<RowDataPacket[]>(`
      SELECT
        sr.id,
        s.name   AS service_name,
        CONCAT(v.make, ' ', v.model, ' — ', v.plate_number) AS vehicle_info,
        p.name   AS personnel_name,
        DATE_FORMAT(sr.service_date, '%Y-%m-%d %H:%i:%s') AS service_date
      FROM service_records sr
      JOIN vehicles v   ON sr.vehicle_id   = v.id
      JOIN services s   ON sr.service_id   = s.id
      JOIN personnel p  ON sr.personnel_id = p.id
      WHERE v.owner_id = ?
      ORDER BY sr.service_date DESC
    `, [userId]);

    return res.status(200).json(rows);
  } catch (err) {
    console.error('My-records handler error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
}
