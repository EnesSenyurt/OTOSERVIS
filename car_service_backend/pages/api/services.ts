

import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../lib/db';
import type { RowDataPacket, OkPacket } from 'mysql2';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    
    if (req.method === 'GET') {
      const [rows] = await pool.query<RowDataPacket[]>(
        `SELECT s.id, s.name, s.description, s.standard_price,
                s.personnel_id, p.name AS personnel_name
         FROM services s
         LEFT JOIN personnel p ON s.personnel_id = p.id`
      );
      return res.status(200).json(rows);
    }

    
    if (req.method === 'POST') {
      const { name, description, standard_price, personnel_id } = req.body;

      if (!name || standard_price == null || !personnel_id) {
        return res
          .status(400)
          .json({ message: 'name, standard_price ve personnel_id zorunlu.' });
      }

      const [result] = await pool.query<OkPacket>(
        `INSERT INTO services
           (name, description, standard_price, personnel_id)
         VALUES (?, ?, ?, ?)`,
        [name, description || '', standard_price, personnel_id]
      );

      return res.status(201).json({
        id: result.insertId,
        name,
        description: description || '',
        standard_price,
        personnel_id,
      });
    }

    
    res.status(405).end();
  } catch (err) {
    console.error('Services handler error:', err);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
}
