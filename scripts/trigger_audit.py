import os
import json
import firebase_admin
from firebase_admin import credentials, messaging

def trigger_audit():
    print("Mempersiapkan amunisi Sinyal Audit...")
    
    # 1. Mengambil JSON rahasia dari Brankas GitHub Actions (Environment Variable)
    cred_json = os.environ.get('FIREBASE_CREDENTIALS')
    if not cred_json:
        print("❌ ERROR FATAL: Kunci Firebase tidak ditemukan di brankas!")
        return

    # 2. Membaca JSON dan Membuka Akses ke Google
    try:
        cred_dict = json.loads(cred_json)
        cred = credentials.Certificate(cred_dict)
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"❌ ERROR OTENTIKASI: Kunci rusak atau tidak valid. Detail: {e}")
        return

    # 3. Merakit peluru Silent Push khusus untuk topik 'audit_harian'
    message = messaging.Message(
        data={
            'action': 'TRIGGER_AUDIT',
        },
        topic='audit_harian',
    )

    # 4. Tarik Pelatuknya!
    try:
        response = messaging.send(message)
        print(f"🔥 MISI SUKSES BESAR! Sinyal Audit diledakkan serentak ke semua HP di dunia.")
        print(f"🆔 ID Tembakan: {response}")
    except Exception as e:
        print(f"❌ GAGAL MENEMBAK: {e}")

if __name__ == '__main__':
    trigger_audit()