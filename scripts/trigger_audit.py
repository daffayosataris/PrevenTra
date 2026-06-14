import os
import json
import firebase_admin

from firebase_admin import (
    credentials,
    messaging
)

def trigger_audit():
    print(
        "Mempersiapkan amunisi Sinyal Audit..."
    )

    cred_json = os.environ.get(
        "FIREBASE_CREDENTIALS"
    )

    if not cred_json:
        print(
            "❌ FIREBASE_CREDENTIALS tidak ditemukan"
        )
        return

    try:
        cred_dict = json.loads(
            cred_json
        )

        cred = credentials.Certificate(
            cred_dict
        )

        if not firebase_admin._apps:
            firebase_admin.initialize_app(
                cred
            )

    except Exception as e:
        print(
            f"❌ ERROR OTENTIKASI: {e}"
        )
        return

    message = messaging.Message(
        notification=messaging.Notification(
            title="PrevenTra Audit",
            body="Menjalankan audit otomatis"
        ),
        data={
            "action": "TRIGGER_AUDIT"
        },
        android=messaging.AndroidConfig(
            priority="high"
        ),
        topic="audit_harian"
    )

    try:
        response = messaging.send(
            message
        )

        print(
            "🔥 MISI SUKSES BESAR!"
        )

        print(
            f"🆔 ID Tembakan: {response}"
        )

    except Exception as e:
        print(
            f"❌ GAGAL MENEMBAK: {e}"
        )

if __name__ == "__main__":
    trigger_audit()