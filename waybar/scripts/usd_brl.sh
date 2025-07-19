#!/bin/bash

API_URL="https://economia.awesomeapi.com.br/json/last/USD-BRL"

response=$(curl -s "$API_URL")

# Verifica se a resposta contém o campo esperado
if [[ -n "$response" ]] && echo "$response" | jq -e '.USDBRL.bid' >/dev/null 2>&1; then
  value=$(echo "$response" | jq -r '.USDBRL.bid')
  printf "💵 USD: R$%.2f\n" "$value"
else
  echo "💵 USD: erro"
fi
