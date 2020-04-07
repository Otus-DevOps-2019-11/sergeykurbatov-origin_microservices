#!/bin/bash
{

cat > configs/service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "Moscow",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Moscow"
    }
  ]
}
EOF

cfssl gencert \
  -ca=certs/ca.pem \
  -ca-key=certs/ca-key.pem \
  -config=configs/ca-config.json \
  -profile=kubernetes \
  configs/service-account-csr.json | cfssljson -bare certs/service-account

}
