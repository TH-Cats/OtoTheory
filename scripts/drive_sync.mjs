import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { google } from 'googleapis';

function getMime(file) {
  const ext = path.extname(file).toLowerCase();
  if (ext === '.md') return 'text/markdown';
  if (ext === '.txt') return 'text/plain';
  return 'application/octet-stream';
}

function parseServiceAccount(raw) {
  // 受け取った文字列がJSONでなければBASE64として再解釈する
  try {
    return JSON.parse(raw);
  } catch (_) {
    try {
      const decoded = Buffer.from(raw, 'base64').toString('utf8');
      return JSON.parse(decoded);
    } catch (err) {
      throw new Error('GDRIVE_SA_JSON is not valid JSON nor base64-encoded JSON');
    }
  }
}

async function driveClient() {
  const sa = process.env.GDRIVE_SA_JSON;
  if (!sa) throw new Error('Missing GDRIVE_SA_JSON');
  const creds = parseServiceAccount(sa);
  const auth = new google.auth.JWT(
    creds.client_email,
    undefined,
    creds.private_key,
    ['https://www.googleapis.com/auth/drive.file']
  );
  await auth.authorize();
  return google.drive({ version: 'v3', auth });
}

async function findByName(drive, folderId, name) {
  try {
    const driveId = process.env.GDRIVE_DRIVE_ID; // Optional: Shared Drive ID
    const res = await drive.files.list({
      q: `name = '${name.replace(/'/g, "\\'")}' and '${folderId}' in parents and trashed = false`,
      fields: 'files(id,name)',
      pageSize: 1,
      includeItemsFromAllDrives: true,
      supportsAllDrives: true,
      corpora: driveId ? 'drive' : 'user',
      driveId: driveId || undefined,
    });
    return res.data.files?.[0] ?? null;
  } catch (e) {
    console.warn('findByName failed, will try create instead:', e?.message || e);
    return null;
  }
}

async function upsertFile(drive, folderId, localPath) {
  const name = path.basename(localPath);
  const mimeType = getMime(localPath);
  const media = { mimeType, body: fs.createReadStream(localPath) };
  const existing = await findByName(drive, folderId, name);
  try {
    if (existing?.id) {
      await drive.files.update({ fileId: existing.id, media, supportsAllDrives: true });
      console.log(`Updated: ${name}`);
    } else {
      await drive.files.create({
        requestBody: { name, parents: [folderId], mimeType },
        media,
        fields: 'id',
        supportsAllDrives: true,
      });
      console.log(`Uploaded: ${name}`);
    }
  } catch (e) {
    console.error('Upload/update failed:', e?.response?.data || e?.message || e);
    throw e;
  }
}

async function main() {
  const ssotFolder = process.env.GDRIVE_FOLDER_SSOT;
  const reportsFolder = process.env.GDRIVE_FOLDER_REPORTS;
  if (!ssotFolder || !reportsFolder) throw new Error('Missing folder IDs');

  const drive = await driveClient();
  const root = process.cwd();

  // SSOT主要ファイル
  const ssot = path.join(root, 'docs/SSOT/OtoTheory_v3.0_SSOT.md');
  if (fs.existsSync(ssot)) await upsertFile(drive, ssotFolder, ssot);

  // レポート群
  const reportsDir = path.join(root, 'reports');
  if (fs.existsSync(reportsDir)) {
    const files = fs.readdirSync(reportsDir).filter((n) => n.endsWith('.md'));
    for (const f of files) {
      await upsertFile(drive, reportsFolder, path.join(reportsDir, f));
    }
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});


