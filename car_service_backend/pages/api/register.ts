import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../lib/db';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';
dotenv.config();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') { res.status(405).end(); return; }
  const { name, email, password } = req.body;
  if (!name || !email || !password) { res.status(400).json({ message: 'Eksik alan' }); return; }
  const [exists] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
  if ((exists as any[]).length) { res.status(409).json({ message: 'Email zaten var' }); return; }
  const hash = await bcrypt.hash(password, 10);
  await pool.query('INSERT INTO users (name,email,password_hash,role) VALUES (?,?,?,?)', [name,email,hash,'user']);
  res.status(201).json({ message: 'Kullanıcı oluşturuldu' });
}
