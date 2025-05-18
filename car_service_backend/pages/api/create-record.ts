

import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../lib/db';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import type { RowDataPacket } from 'mysql2';
dotenv.config();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).end();

  
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

  
  const { vehicleId, serviceId, scheduledAt, notes } = req.body;
  if (!vehicleId || !serviceId || !scheduledAt) {
    return res.status(400).json({ message: 'vehicleId, serviceId ve scheduledAt zorunlu' });
  }

  
  const dt = String(scheduledAt).replace('T', ' ').substring(0, 19);

  try {
    
    const [vRows] = await pool.query<RowDataPacket[]>(
      'SELECT id FROM vehicles WHERE id = ? AND owner_id = ?',
      [vehicleId, userId]
    );
    if (!vRows.length) {
      return res.status(404).json({ message: 'Araç bulunamadı' });
    }

    
    const [sRows] = await pool.query<RowDataPacket[]>(
      'SELECT personnel_id FROM services WHERE id = ?',
      [serviceId]
    );
    if (!sRows.length) {
      return res.status(404).json({ message: 'Service not found' });
    }
    const personnelId = sRows[0].personnel_id as number | null;
    if (personnelId == null) {
      return res
        .status(400)
        .json({ message: 'Bu hizmetin sorumlu personeli atanmamış.' });
    }

    
    await pool.query(
      `INSERT INTO service_records
          (vehicle_id, service_id, personnel_id, service_date, created_by, notes)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [vehicleId, serviceId, personnelId, dt, userId, notes || null]
    );

    return res.status(201).json({ message: 'Service record created' });
  } catch (err) {
    console.error('Create-record handler error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
}
