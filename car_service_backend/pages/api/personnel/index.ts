import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../../lib/db';
import type { RowDataPacket, OkPacket } from 'mysql2';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    if (req.method === 'GET') {
      const [rows] = await pool.query<RowDataPacket[]>('SELECT id,name,position,contact FROM personnel');
      res.status(200).json(rows);
      return;
    }
    if (req.method === 'POST') {
      const { name,position,contact } = req.body;
      if (!name||!position) { res.status(400).json({ message: 'Eksik alan' }); return; }
      const [r] = await pool.query<OkPacket>(
        'INSERT INTO personnel(name,position,contact) VALUES(?,?,?)',
        [name,position,contact||'']
      );
      res.status(201).json({ id:(r as any).insertId,name,position,contact });
      return;
    }
    res.status(405).end();
  } catch(err){
    console.error(err);
    res.status(500).json({ message:'Server error' });
  }
}
