# Generica-Database para Delphi
![Delphi Supported Versions](https://img.shields.io/badge/Vers%C3%B5es%20do%20Delphi%20Suportadas-XE10%20Seatle%20..%20XE10.4%20Sydney-blue.svg)
![Platforms](https://img.shields.io/badge/Plataformas%20Suportadas-Win32%20..%20Win64-red.svg)
 
Generic-Database é um Conjunto de Classes para Conexão Genérica à Bancos de Dados e Exibição dos Dados em Componentes Nativos da IDE de Forma Rápida, Simples e Prática

RMDB/SGDB Suportados Atualmente: SQLite, MySQL/MariaDB, PostgreSQL e FireBird [¹]
DataBase Frameworks Suportados Atualmente: dbExpress, ZeOsLib e FireDAC [²]

## Classes Adicionais
[*] Adição de Matriz Associativa e Multidimensionais PHP-Like;
[*] Para Suprir a Ausência de Componentes Nativos em Firemonkey do Tipo DB* como DBGrid, DBEdit, DBCombo e etc;
 
## Instalação Usando Boss (Gerenciador de Dependências para Aplicações em Delphi)
```
boss install github.com/nicksonjean/Generic-Database
```

## Instalação Manual
Adicione as Seguintes Pastas ao Seu Projeto, em *Project > Options > Resource Compiler > Directories and Conditionals > Include file search path*
```
../Generic-Database/Source/
../Generic-Database/Source/Types
../Generic-Database/Source/Types/Locale
../Generic-Database/Source/Connection/Connector
```

[¹] ToDo para Suportar o Oracle, SQLServer, MSSQL e InterBase
[²] ToDo para Suportar o UniDAC
[-] ToDo para Suportar o Component TeeGrid em ComponentConnector
[-] ToDo para Criar um DBNavigator para TGrid e TStringGrid
[-] ToDo para Criar a Funcionalidade de Carregar Mais on Scroll para ListBox e ListView
[-] ToDo para Criar a Paginação para Carregar Mais para ListBox e ListView