import os
import json
import firebase_admin
from firebase_admin import credentials, messaging

def main():
    # Mengambil kunci rahasia dari brankas GitHub Secrets
    creds_json = os.environ.get('FIREBASE_CREDENTIALS')
    device_token = os.environ.get('FCM_DEVICE_TOKEN')

    if not creds_json or not device_token:
        print("ERROR FATAL: Kunci Firebase atau Token FCM tidak ditemukan di Environment!")
        return

    # Inisialisasi Firebase Admin dengan kunci JSON
    cred_dict = json.loads(creds_json)
    cred = credentials.Certificate(cred_dict)
    firebase_admin.initialize_app(cred)

    # Merakit peluru Silent Push Notification
    # Kita menggunakan "data" agar aplikasi terbangun di background (sesuai logika main.dart Anda)
    message = messaging.Message(
        data={
            'action': 'TRIGGER_AUDIT'
        },
        token=device_token
    )

    # Menembakkan sinyal ke HP Yang Mulia
    try:
        response = messaging.send(message)
        print(f'MISI SUKSES! Sinyal TRIGGER_AUDIT berhasil ditembakkan. ID Pesan: {response}')
    except Exception as e:
        print(f'GAGAL MENEMBAK: {e}')

if __name__ == '__main__':
    main()