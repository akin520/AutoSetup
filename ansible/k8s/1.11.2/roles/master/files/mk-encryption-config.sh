SECRET=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: $SECRET
      - identity: {}
EOF
