#!/bin/bash
{

cat > configs/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "RU",
      "L": "Moscow",
      "O": "system:node-proxier",
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
  configs/kube-proxy-csr.json | cfssljson -bare certs/kube-proxy

}
