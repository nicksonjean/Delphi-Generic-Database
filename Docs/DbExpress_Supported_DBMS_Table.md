# dbExpress supported DBMS (table)

dbExpress provides built-in support for the following Database Management Systems (DBMS):

**Source:** [DbExpress Supported Database Management Systems (RAD Studio Florence)](https://docwiki.embarcadero.com/RADStudio/Florence/en/DbExpress_Supported_Database_Management_Systems)

*Em **negrito**: entradas cobertas pelo adapter dbExpress deste repositório (`dbExpress.ConnectionStrategy.RegisterDrivers`): SQLite, MySQL, Firebird, InterBase Server, MSSQL e Oracle. **PostgreSQL** (Devart) também está implementado no código, mas não consta na tabela oficial Embarcadero.*

A tabela abaixo está em **HTML embutido** para permitir `rowspan` / `colspan` (GFM não oferece isso em tabelas com pipes).

<table border="1" cellpadding="6" cellspacing="0" width="100%" style="border-collapse: collapse;">
  <tbody>
    <tr>
      <th rowspan="2">Database Management System</th>
      <th rowspan="2">Supported Versions</th>
      <th rowspan="2"><a href="https://docwiki.embarcadero.com/RADStudio/Florence/en/Supported_Target_Platforms" title="Supported Target Platforms">Supported Platforms</a></th>
      <th colspan="2">Required Libraries</th>
      <th rowspan="2">DriverID parameter</th>
    </tr>
    <tr>
      <th>Driver</th>
      <th>Client**</th>
    </tr>
    <tr>
      <td rowspan="2">ASA (Sybase SQL Anywhere)</td>
      <td rowspan="2">12<br>11<br>10<br>9<br>8*</td>
      <td>32-bit Windows<br>64-bit Windows</td>
      <td>dbxasa.dll</td>
      <td>dbodbc*.dll</td>
      <td rowspan="2">ASA</td>
    </tr>
    <tr>
      <td>macOS</td>
      <td>libsqlasa.dylib</td>
      <td>libdbodbc12.dylib</td>
    </tr>
    <tr>
      <td rowspan="2">ASE (Sybase ASE)</td>
      <td rowspan="2">12.5</td>
      <td>32-bit Windows</td>
      <td rowspan="2">dbxase.dll</td>
      <td>libct.dll<br>libcs.dll</td>
      <td rowspan="2">ASE</td>
    </tr>
    <tr>
      <td>64-bit Windows</td>
      <td>libsybct64.dll<br>libsybcs64.dll</td>
    </tr>
    <tr>
      <td rowspan="2">DB2</td>
      <td rowspan="2">9.5<br>9.1<br>8.x*<br>7.x*</td>
      <td rowspan="2">32-bit Windows<br>64-bit Windows</td>
      <td rowspan="2">dbxdb2.dll</td>
      <td>db2cli.dll</td>
      <td rowspan="2">DB2</td>
    </tr>
    <tr>
      <td>db2cli64.dll</td>
    </tr>
    <tr>
      <td rowspan="4">DataSnap</td>
      <td rowspan="4"></td>
      <td>32-bit Windows</td>
      <td colspan="2">midas.dll</td>
      <td rowspan="4">DataSnap</td>
    </tr>
    <tr>
      <td>64-bit Windows</td>
      <td colspan="2">midas.dll</td>
    </tr>
    <tr>
      <td>32-bit Android<br>64-bit Android<br>32-bit iOS Device<br>64-bit iOS Device</td>
      <td colspan="2">libmidas.a</td>
    </tr>
    <tr>
      <td>macOS</td>
      <td colspan="2">libmidas.dylib</td>
    </tr>
    <tr>
      <td rowspan="2"><strong>Firebird</strong></td>
      <td rowspan="2">3.0*<br>2.5<br>2.1<br>1.5</td>
      <td>32-bit Windows<br>64-bit Windows</td>
      <td><strong>dbxfb.dll</strong></td>
      <td><strong>fbclient.dll</strong></td>
      <td rowspan="2"><strong>Firebird</strong></td>
    </tr>
    <tr>
      <td>macOS</td>
      <td><strong>libsqlfb.dylib</strong></td>
      <td><strong>/Library/Frameworks/Firebird.framework/Firebird</strong></td>
    </tr>
    <tr>
      <td rowspan="4">IBLite/ToGo</td>
      <td rowspan="4">XE3</td>
      <td>32-bit Windows</td>
      <td rowspan="2">dbxint.dll</td>
      <td>ibtogo.dll</td>
      <td rowspan="4">IBLite/ToGo</td>
    </tr>
    <tr>
      <td>64-bit Windows</td>
      <td>ibtogo64.dll</td>
    </tr>
    <tr>
      <td>32-bit Android<br>64-bit Android<br>32-bit iOS Device<br>64-bit iOS Device</td>
      <td>Functionality provided by the Data.DBXInterBase unit.</td>
      <td>libibtogo.a<br>(statically linked, no need to deploy)</td>
    </tr>
    <tr>
      <td>macOS</td>
      <td>libsqlib.dylib</td>
      <td>libibtogo.dylib</td>
    </tr>
    <tr>
      <td rowspan="2">Informix</td>
      <td rowspan="2">9.x</td>
      <td>32-bit Windows<br>64-bit Windows</td>
      <td>dbxinf.dll</td>
      <td>isqlb09a.dll</td>
      <td rowspan="2">Informix</td>
    </tr>
    <tr>
      <td>macOS</td>
      <td>libsqlinf.dylib</td>
      <td>libifcli.dylib</td>
    </tr>
    <tr>
      <td rowspan="3"><strong>InterBase Server</strong></td>
      <td rowspan="3">XE3<br>XE<br>2009<br>2007<br>7.5.1<br>7.1*<br>8.0*<br>6.5*</td>
      <td>32-bit Windows</td>
      <td rowspan="2"><strong>dbxint.dll</strong></td>
      <td><strong>gds32.DLL</strong></td>
      <td rowspan="3"><strong>InterBase Server</strong></td>
    </tr>
    <tr>
      <td>64-bit Windows</td>
      <td><strong>ibclient64.dll</strong></td>
    </tr>
    <tr>
      <td>macOS</td>
      <td><strong>libsqlib.dylib</strong></td>
      <td><strong>libgds.dylib</strong></td>
    </tr>
    <tr>
      <td rowspan="2"><strong>MSSQL (Microsoft SQL Server)</strong></td>
      <td rowspan="2">2008<br>2005<br>2000</td>
      <td rowspan="2">32-bit Windows<br>64-bit Windows</td>
      <td><strong>dbxmss.dll</strong></td>
      <td><strong>sqlncli10.dll</strong></td>
      <td rowspan="2"><strong>MSSQL</strong></td>
    </tr>
    <tr>
      <td><strong>dbxmss9.dll</strong></td>
      <td><strong>sqlncli.dll</strong></td>
    </tr>
    <tr>
      <td rowspan="2"><strong>MySQL</strong></td>
      <td rowspan="2">5.1<br>5.0.27<br>4.1*</td>
      <td>32-bit Windows<br>64-bit Windows</td>
      <td><strong>dbxmys.dll</strong></td>
      <td><strong>libmysql.dll</strong></td>
      <td rowspan="2"><strong>MySQL</strong></td>
    </tr>
    <tr>
      <td>macOS</td>
      <td><strong>libsqlmys.dylib</strong></td>
      <td><strong>libmysqlclient.dylib</strong></td>
    </tr>
    <tr>
      <td>ODBC<br>(bridge to several database management systems)</td>
      <td></td>
      <td>32-bit Windows<br>64-bit Windows</td>
      <td>Functionality provided by the Data.DBXOdbc unit.</td>
      <td></td>
      <td>Odbc</td>
    </tr>
    <tr>
      <td rowspan="2"><strong>Oracle</strong></td>
      <td rowspan="2">11g<br>10g<br>9.2.0*<br>9.1.0*</td>
      <td>32-bit Windows<br>64-bit Windows</td>
      <td><strong>dbxora.dll</strong></td>
      <td><strong>oci.dll</strong></td>
      <td rowspan="2"><strong>Oracle</strong></td>
    </tr>
    <tr>
      <td>macOS</td>
      <td><strong>libsqlora.dylib</strong></td>
      <td><strong>libociei.dylib</strong></td>
    </tr>
    <tr>
      <td rowspan="4"><strong>SQLite</strong></td>
      <td rowspan="4">3.x</td>
      <td>32-bit Windows<br>64-bit Windows</td>
      <td><strong>Functionality provided by the Data.DbxSqlite unit.</strong></td>
      <td><strong>sqlite3.dll</strong></td>
      <td rowspan="4"><strong>Sqlite</strong></td>
    </tr>
    <tr>
      <td>32-bit Android<br>64-bit Android</td>
      <td></td>
      <td><strong>sqlite.so<br>(system-provided, no need to deploy)</strong></td>
    </tr>
    <tr>
      <td>32-bit iOS Device<br>64-bit iOS Device</td>
      <td></td>
      <td><strong>libsqlite3.dylib<br>(system-provided, no need to deploy)</strong></td>
    </tr>
    <tr>
      <td>macOS</td>
      <td></td>
      <td><strong>libsqlite3.dylib</strong></td>
    </tr>
  </tbody>
</table>

## Notes

- Drivers are not fully certified with versions of database management systems marked with *.
- Clients are available for download from the vendors' websites.
- Not every edition of RAD Studio supports every database management system listed above.
- Third-party vendors may provide dbExpress drivers that provide support for additional database management systems.
- **Firebird 3.0\*** aparece no topo da coluna de versões como referência para Windows 32/64; uso com **limitações** e **fora** do suporte oficial Embarcadero nesta tabela (versões documentadas pela Embarcadero: 2.5, 2.1, 1.5).
