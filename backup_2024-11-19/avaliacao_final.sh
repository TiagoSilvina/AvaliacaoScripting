#!/bin/bash

if [ -z "$1" ]; then
    read -p "Escolha um caminho : " caminho
else
    caminho="$1"
fi

if [ ! -d "$caminho" ]; then
    while [ ! -d "$caminho" ]; do
        echo "Caminho não encontrado"
        read -p "Escolha um caminho válido: " caminho
    done
fi

if [ -z "$2" ]; then
    read -p "Escolha uma cidade: " cidade
else
    cidade="$2"
fi

ls -lhS "$1" 

quant_s=0
quant_m=0
quant_l=0
total_palavras=0
total_arquivos=0
maior_quant_palavras=0
maior_arquivo=""
lista_nomes=""

for arquivo in $(ls -lhS "$1" )/*; do
    if [ -f "$arquivo" ]; then
        quant_palavras=$(wc -w < "$arquivo") 
        total_palavras=$((total_palavras + quant_palavras))
        total_arquivos=$((total_arquivos + 1))

        if [ "$quant_palavras" -le 1000 ]; then
            ((quant_s++))
            categoria="pequeno"
        elif [ "$quant_palavras" -le 10000 ]; then
            ((quant_m++))
            categoria="médio"
        else
            ((quant_l++))
            categoria="grande"
        fi

        if [ "$quant_palavras" -gt "$maior_quant_palavras" ]; then
            maior_quant_palavras=$quant_palavras
            maior_arquivo="$arquivo"
        fi

        nome=$(basename "$arquivo")
        lista_nomes="$lista_nomes$nome - Categoria: $categoria"$'\n'
    fi
done

if [ "$total_arquivos" -gt 0 ]; then
    media_palavras=$((total_palavras / total_arquivos))  
else
    media_palavras=0  
fi

URL="https://api.openweathermap.org/data/2.5/weather?q=$2&appid=79562f8cfbf795505ad36561e845f745"
infoTempo=$(curl "$URL")
temperatura=$(echo "$infoTempo" | grep -o '"temp":[^,]*' | cut -d: -f2)
condicao=$(echo "$infoTempo" | grep -o '"description":"[^"]*' | cut -d: -f2 | tr -d '"')

backup="backup_$(date +%Y-%m-%d)"
relatorio="relatorio_$(date +%Y-%m-%d).txt"

mkdir "$backup"

{
    echo "Caminho: $1"
    echo " "
    echo "Lista de arquivos:"
    echo "$lista_nomes" 
    echo "Arquivos pequenos (<=1000 palavras): $quant_s"
    echo "Arquivos médios (1000-10000 palavras): $quant_m"
    echo "Arquivos grandes (>10000 palavras): $quant_l"
    echo "Total de arquivos processados: $total_arquivos"
    echo "Média de palavras por arquivo: $media_palavras"
    echo "Arquivo com maior número de palavras: $(basename "$maior_arquivo") ($maior_quant_palavras palavras)"
    echo "Cidade: $2"
    echo "Temperatura: $temperatura"
    echo "Condição do tempo: $condicao"
} > "$backup/$relatorio"

cp "$1"/* "$backup/"

ls -lhS "$backup" 

cat "$backup/$relatorio"


#Directory
#/c/Users/tiago/Desktop/Citeforma/DataAnalytics/Scripting/AvaliacaoScripting/