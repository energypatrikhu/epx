__epx_mk_cert() {
  _cci openssl

  local DOMAIN="${1-}"
  if [[ -z "$DOMAIN" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Mk Cert")] $(_c LIGHT_YELLOW "Usage: epx mk-cert <domain>")"
    echo -e "[$(_c LIGHT_BLUE "Mk Cert")] $(_c LIGHT_YELLOW "Example: epx mk-cert example.com")"
    return 1
  fi

  local WILDCARD="*.$DOMAIN"

  echo -e "[$(_c LIGHT_BLUE "Mk Cert")] $(_c LIGHT_GREEN "Creating self-signed certificate for wildcard domain: $WILDCARD")"

  cat <<EOF > req.cnf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = HU
ST = HU
O = $DOMAIN
localityName = $DOMAIN
commonName = $WILDCARD
organizationalUnitName = $DOMAIN

[v3_req]
basicConstraints = CA:TRUE
subjectKeyIdentifier = hash
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1   = $DOMAIN
DNS.2   = *.$DOMAIN
EOF

  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout "$DOMAIN.key" -config req.cnf \
    -out "$DOMAIN.crt" -sha256
  rm req.cnf

  echo -e "[$(_c LIGHT_BLUE "Mk Cert")] $(_c LIGHT_GREEN "Self-signed certificate creation completed successfully.")"
  echo ""
  echo -e "[$(_c LIGHT_BLUE "Mk Cert")] $(_c LIGHT_YELLOW "Next manual steps:")"
  echo -e "[$(_c LIGHT_BLUE "Mk Cert")] $(_c LIGHT_YELLOW "- Use") $DOMAIN.crt $(_c LIGHT_YELLOW "and") $DOMAIN.key $(_c LIGHT_YELLOW "to configure Apache/nginx")"
  echo -e "[$(_c LIGHT_BLUE "Mk Cert")] $(_c LIGHT_YELLOW "- Import") $DOMAIN.crt $(_c LIGHT_YELLOW "into Chrome settings:") chrome://settings/certificates $(_c LIGHT_YELLOW "> tab '") 'Authorities'"
}
