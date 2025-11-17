#!/bin/bash
# zowe_operations.sh

echo "--- Debugging Zowe CLI connection variables ---"
echo "ZOWE_ZOSMF_HOST: $ZOWE_ZOSMF_HOST"
echo "ZOWE_ZOSMF_PORT: $ZOWE_ZOSMF_PORT"
echo "ZOWE_ZOSMF_USER: $ZOWE_ZOSMF_USER"
echo "ZOWE_ZOSMF_PASSWORD: ${ZOWE_ZOSMF_PASSWORD:0:1}***" # Máscara para não expor a senha completa nos logs
echo "ZOWE_USERNAME (for path construction): $ZOWE_USERNAME"
echo "---------------------------------------------"

# Definir os argumentos de conexão do Zowe CLI usando as variáveis de ambiente
ZOWE_CLI_CONN_ARGS="--host $ZOWE_ZOSMF_HOST --port $ZOWE_ZOSMF_PORT --user $ZOWE_ZOSMF_USER --password $ZOWE_ZOSMF_PASSWORD --reject-unauthorized false"
echo "Constructed ZOWE_CLI_CONN_ARGS: $ZOWE_CLI_CONN_ARGS"
echo "---------------------------------------------"

# Convert username to lowercase (ZOWE_USERNAME é o secret original)
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Check if directory exists, create if it doesn't
# Passando explicitamente os argumentos de conexão
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_CLI_CONN_ARGS &>/dev/null; then
  echo "Directory does not exist. Creating it..."
  zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_CLI_CONN_ARGS
else
  echo "Directory already exists."
fi

# Upload files
# Passando explicitamente os argumentos de conexão
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "cobol-check-0.2.9.jar" $ZOWE_CLI_CONN_ARGS

# Verify upload
echo "Verifying upload:"
# Passando explicitamente os argumentos de conexão
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" $ZOWE_CLI_CONN_ARGS
