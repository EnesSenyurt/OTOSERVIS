import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../../lib/db';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
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
  const { id } = req.query;
  const orderId = Array.isArray(id) ? parseInt(id[0], 10) : parseInt(id as string, 10);

  if (req.method === 'PUT') {
    if (!verifyAdmin(req, res)) return;
    const { status } = req.body;
    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'Geçersiz status' });
    }
    await pool.query(
      `UPDATE part_orders SET status = ? WHERE id = ?`,
      [status, orderId]
    );
    return res.status(200).json({ message: 'Güncellendi' });
  }

  return res.status(405).end();
}
