// backend/pages/api/services/[id].ts

import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../../lib/db';
import type { OkPacket } from 'mysql2';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query;
  if (req.method === 'DELETE') {
    try {
      await pool.query<OkPacket>('DELETE FROM services WHERE id = ?', [id]);
      res.status(204).end();
    } catch (err) {
      console.error('Delete service error', err);
      res.status(500).json({ message: 'Server error' });
    }
    return;
  }
  res.status(405).end();
}
