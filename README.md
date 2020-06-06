# Generica-Database para Delphi
![Delphi Supported Versions](https://img.shields.io/badge/Vers%C3%B5es%20do%20Delphi%20Suportadas-XE10%20Seatle%20..%20XE10.4%20Sydney-blue.svg)
![Platforms](https://img.shields.io/badge/Plataformas%20Suportadas-Win32%20..%20Win64-red.svg)
 
Generic-Database é um Conjunto de Classes para Conexão Genérica à Bancos de Dados e Exibição dos Dados em Componentes Nativos da IDE de Forma Rápida, Simples e Prática

- RMDB/SGDB Suportados Atualmente: SQLite, MySQL/MariaDB, PostgreSQL e FireBird ¹
- DataBase Frameworks Suportados Atualmente: dbExpress, ZeOsLib e FireDAC ²

## Classes Adicionais
- Array.pas - Esta Classe Fornece a Capacidade de Criar Matrizes Associativas e Multidimensionais PHP-Like, Possuindo Quatro Variantes;
 - 1) ArrayString - Classe Bidimensional Associativa Exclusivamente de Strings, Herdada de TStringList;
 - 2) ArrayVariant - Classe Bidimensional Associativa Baseada em Generics, Herdada de TDictionary<Variant, Variant>;
 - 3) ArrayField - Classe Bidimensional Associativa Baseada em Generics, Herdada de TDictionary<Variant, TField>;
 - 4) ArrayAssoc - Classe Multidimensional Associativa Baseada em Gererics, Herdada de TDictionary<Variant, TPair<Variant, TArrayAssoc>>;
- Connectors.pas - Esta Classe Fornece uma Série de Métodos que são Capazes de Simular o Comportamente dos Componentes do Tipo DB* Presentes Nativamente em VCL como DBGrid, DBEdit, DBCombo e etc, nos Componentes Nativos do Firemonkey, Conectando uma Query Inclusive de Forma Bidirecional e Exibindo seu Resultado Diretamente nos Componentes, Suprindo Assim a Ausência de Componentes Nativos em Firemonkey do Tipo DB*.
 - Todos os Componentes Listados Abaixo, Ganharam um Connector;
  - TEdit - Com o Método ToEdit;
  - TComboBox - Com o Método TpComboBox;
  - TComboEdit - Com o Método ToComboEdit;
  - TGrid - Com o Método ToGrid; 
  - TStringGrid - Com o Método ToStringGrid; 
  - TListBox - Com o Método ToListBox; 
  - TListView - Com o Método ToListView; 
 
## Instalação Usando Boss (Gerenciador de Dependências para Aplicações em Delphi)
```
boss install github.com/nicksonjean/Generic-Database
```

## Instalação Manual
Adicione as Seguintes Pastas ao Seu Projeto, em *Project > Options > Resource Compiler > Directories and Conditionals > Include file search path*
```
../Generic-Database/Source/
../Generic-Database/Source/Connection
../Generic-Database/Source/Types
../Generic-Database/Source/Types/Locale
../Generic-Database/Source/Connector
../Generic-Database/Source/EventDriven
../Generic-Database/Source/Extensions
../Generic-Database/Source/Helpers
```

### ToDo

- [ ] Suportar o Oracle, SQLServer, MSSQL e InterBase
- [ ] Suportar o UniDAC
- [ ] Suportar o Component TeeGrid em ComponentConnector
- [ ] Criar um DBNavigator para TGrid e TStringGrid
- [ ] Criar a Funcionalidade de Carregar Mais on Scroll para ListBox e ListView
- [ ] Criar a Paginação para Carregar Mais para ListBox e ListView

⁰¹²³⁴⁵⁶⁷⁸⁹