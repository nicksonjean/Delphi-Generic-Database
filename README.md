# generic-dbal
![Delphi Supported Versions](https://img.shields.io/badge/Vers%C3%B5es%20do%20Delphi%20Suportadas-XE10%20Seatle%20..%20XE10.4%20Sydney-blue.svg)
![Platforms](https://img.shields.io/badge/Plataformas%20Suportadas-Win32%20..%20Win64-red.svg)
 
generic-dbal é um Conjunto de Classes para Conexão Genérica à Bancos de Dados e Exibição dos Dados em Componentes Nativos da IDE de Forma Rápida, Simples e Prática

- RMDB/SGDB Suportados Atualmente: SQLite, Firebird/Interbase, MySQL/MariaDB, PostgreSQL, SQLServer e Oracle
- DBAL Suportados Atualmente: FireDAC, dbExpress e ZeOsLib

## Classes Adicionais
- Array.pas - Esta Classe Fornece a Capacidade de Criar Matrizes Associativas e Multidimensionais PHP-Like, Possuindo Quatro Variantes;
 - 1) ArrayString - Classe Bidimensional Associativa Exclusivamente de Strings, Herdada de TStringList;
 - 2) ArrayVariant - Classe Bidimensional Associativa Baseada em Generics, Herdada de TDictionary<Variant, Variant>;
 - 3) ArrayField - Classe Bidimensional Associativa Baseada em Generics, Herdada de TDictionary<Variant, TField>;
 - 4) ArrayAssoc - Classe Multidimensional Associativa Baseada em Gererics, Herdada de TDictionary<Variant, TPair<Variant, TArrayAssoc>>;
- Connectors.pas - Esta Classe Fornece uma Série de Métodos que são Capazes de Simular o Comportamente dos Componentes do Tipo DB* Presentes Nativamente em VCL como DBGrid, DBEdit, DBCombo e etc, nos Componentes Nativos do Firemonkey, Conectando uma Query Inclusive de Forma Bidirecional e Exibindo seu Resultado Diretamente nos Componentes, Suprindo Assim a Ausência de Componentes Nativos em Firemonkey do Tipo DB*.
 - Todos os Componentes Listados Abaixo, Ganharam um Connector;
  - TEdit - Com o Método ToEdit;
  - TComboBox - Com o Método ToComboBox;
  - TComboEdit - Com o Método ToComboEdit;
  - TGrid - Com o Método ToGrid; 
  - TStringGrid - Com o Método ToStringGrid; 
  - TListBox - Com o Método ToListBox; 
  - TListView - Com o Método ToListView; 
 
## Instalação Usando Boss (Gerenciador de Dependências para Aplicações em Delphi)
```
boss install github.com/nicksonjean/generic-dbal
```

## Instalação Manual
1) Clone este Repositório com a Linha de Comando Abaixo:
```
git clone https://github.com/nicksonjean/generic-dbal.git
```

2) Em Seguida execute o arquivo install.bat com a Linha de Comando Abaixo:
```
.\generic-dbal\install.bat
```

3) Opcionalmente Adicione as Seguintes Pastas ao Seu Projeto, em *Project > Options > Resource Compiler > Directories and Conditionals > Include file search path*
```
../generic-dbal/Source/Connection
../generic-dbal/Source/Connector
../generic-dbal/Source/EventDriven
../generic-dbal/Source/Extensions
../generic-dbal/Source/Helpers
../generic-dbal/Source/Reflection
../generic-dbal/Source/Types
../generic-dbal/Source/Types/Locale
```
### ToDo

- [ ] Suportar o UniDAC
  - [ ] Suportar o SQLite
  - [ ] Suportar o Firebird/Interbase
  - [ ] Suportar o MySQL/MariaDB
  - [ ] Suportar o PostgreSQL
  - [ ] Suportar o SQLServer
  - [ ] Suportar o Oracle
- [ ] Suportar o Component TeeGrid em Connector
- [ ] Refatorar Removendo Arquivos *.inc
  - [ ] Refatorar Connection.pas
  - [X] Refatorar Types/Array.pas
  - [ ] Refatorar Types/TimeDate.pas
- [ ] Criar um DBNavigator para TGrid e TStringGrid
- [ ] Criar a Funcionalidade de Carregar Mais on Scroll para ListBox e ListView
- [ ] Criar a Paginação para Carregar Mais para ListBox e ListView

⁰¹²³⁴⁵⁶⁷⁸⁹