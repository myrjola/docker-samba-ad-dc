# Docker container demonstrating Samba's Active Directory Domain Controller (AD DC) support

Run these commands to start the container
```
docker build -t samba-ad-dc .
docker run --privileged -v ${PWD}/samba:/var/lib/samba  -e "SAMBA_DOMAIN=smbdc1" -e "SAMBA_REALM=smbdc1.example.com" --name dc1 --dns 127.0.0.1 -d samba-ad-dc
```
You can of course change the domain and realm to your liking.

You get the IP-address of the running machine by issuing `docker inspect dc1 | grep IPAddress` and the root user's
password as well as other passwords by running `docker logs dc1 2>&1 | head -3`. You should then be able to log in with SSH.

One fast check to see that Kerberos talks with Samba:
```
root@1779834e202b:~# kinit administrator@SMBDC1.EXAMPLE.COM
Password for administrator@SMBDC1.EXAMPLE.COM:
Warning: Your password will expire in 41 days on Thu Jul 10 19:36:55 2014
root@1779834e202b:~# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: administrator@SMBDC1.EXAMPLE.COM

Valid starting     Expires            Service principal
05/29/14 19:45:53  05/30/14 05:45:53  krbtgt/SMBDC1.EXAMPLE.COM@SMBDC1.EXAMPLE.COM
        renew until 05/30/14 19:45:43

```

## Redmine client

Now you can test Redmine ldap login to the host.
```
docker run --name redmine -d sameersbn/redmine:latest
REDMINE_IP=$(docker inspect redmine | grep IPAddres | awk -F'"' '{print $4}')
xdg-open "http://${REDMINE_IP}/auth_sources/new"
```

Refresh the browser until the login page shows. Login with both username and password as admin. Fill the form with these credentials:

```
Name: smbdc1
Host: *samba_ad_dc_ip*
Port: 389 [ ] LDAPS
Account: Administrator@smbdc1
Password: *samba_admin_password_here*
Base DN: CN=Users,DC=smbdc1,DC=example,DC=com
LDAP filter:
Timeout (in seconds):

On-the-fly user creation [X]
Attributes:
    Login attribute: sAMAccountName
    Firstname attribute: givenName
    Lastname attribute: sn
    Email attribute: userPrincipalName
```

Now log out and log in with the samba administrator credentials (username: administrator, password: *check with docker log dc1*)

## Windows client

[This](http://vimeo.com/11527979#t=3m15s) is a nice guide to join your Windows 7 client to the DC. Just make sure to have your Docker container as the
[primary DNS server for Windows](http://www.opennicproject.org/configure-your-dns/how-to-change-dns-servers-in-windows-7/).

## LDAP explorers

I used [JXplorer](http://jxplorer.org/) to explore the LDAP-schema. To log in you need to input something like this:
![JXplorer example](http://i.imgur.com/LniIp22.png)

## Resources
I followed the guide on Samba's wiki pages https://wiki.samba.org/index.php/Samba_AD_DC_HOWTO

Port usage: https://wiki.samba.org/index.php/Samba_port_usage

## Port forwarding command
If you want to use the host's IP you can start the box with this:
```
docker run --privileged -p 53:53 -p 53:53/udp -p 88:88 -p 88:88/udp -p 135:135 -p 137:137/udp -p 138:138/udp -p 139:139 -p 389:389 -p 389:389/udp -p 445:445 -p 464:464 -p 464:464/udp -p 636:636 -p 3268:3268 -p 3269:3269 -p 1024:1024 -p 1025:1025 -p 1026:1026 -p 1027:1027 -p 1028:1028 -p 1029:1029 -p 1030:1030 -p 1031:1031 -p 1032:1032 -p 1033:1033 -p 1034:1034 -p 1035:1035 -p 1036:1036 -p 1037:1037 -p 1038:1038 -p 1039:1039 -p 1040:1040 -p 1041:1041 -p 1042:1042 -p 1043:1043 -p 1044:1044 -p 1045:1045 -p 1046:1046 -p 1047:1047 -p 1048:1048 -p 1049:1049 -p 1050:1050 -p 1051:1051 -p 1052:1052 -p 1053:1053 -p 1054:1054 -p 1055:1055 -p 1056:1056 -p 1057:1057 -p 1058:1058 -p 1059:1059 -p 1060:1060 -p 1061:1061 -p 1062:1062 -p 1063:1063 -p 1064:1064 -p 1065:1065 -p 1066:1066 -p 1067:1067 -p 1068:1068 -p 1069:1069 -p 1070:1070 -p 1071:1071 -p 1072:1072 -p 1073:1073 -p 1074:1074 -p 1075:1075 -p 1076:1076 -p 1077:1077 -p 1078:1078 -p 1079:1079 -p 1080:1080 -p 1081:1081 -p 1082:1082 -p 1083:1083 -p 1084:1084 -p 1085:1085 -p 1086:1086 -p 1087:1087 -p 1088:1088 -p 1089:1089 -p 1090:1090 -p 1091:1091 -p 1092:1092 -p 1093:1093 -p 1094:1094 -p 1095:1095 -p 1096:1096 -p 1097:1097 -p 1098:1098 -p 1099:1099 -p 1100:1100 -p 1101:1101 -p 1102:1102 -p 1103:1103 -p 1104:1104 -p 1105:1105 -p 1106:1106 -p 1107:1107 -p 1108:1108 -p 1109:1109 -p 1110:1110 -p 1111:1111 -p 1112:1112 -p 1113:1113 -p 1114:1114 -p 1115:1115 -p 1116:1116 -p 1117:1117 -p 1118:1118 -p 1119:1119 -p 1120:1120 -p 1121:1121 -p 1122:1122 -p 1123:1123 -p 1124:1124 -p 1125:1125 -p 1126:1126 -p 1127:1127 -p 1128:1128 -p 1129:1129 -p 1130:1130 -p 1131:1131 -p 1132:1132 -p 1133:1133 -p 1134:1134 -p 1135:1135 -p 1136:1136 -p 1137:1137 -p 1138:1138 -p 1139:1139 -p 1140:1140 -p 1141:1141 -p 1142:1142 -p 1143:1143 -p 1144:1144 -p 1145:1145 -p 1146:1146 -p 1147:1147 -p 1148:1148 -p 1149:1149 -p 1150:1150 -p 1151:1151 -p 1152:1152 -p 1153:1153 -p 1154:1154 -p 1155:1155 -p 1156:1156 -p 1157:1157 -p 1158:1158 -p 1159:1159 -p 1160:1160 -p 1161:1161 -p 1162:1162 -p 1163:1163 -p 1164:1164 -p 1165:1165 -p 1166:1166 -p 1167:1167 -p 1168:1168 -p 1169:1169 -p 1170:1170 -p 1171:1171 -p 1172:1172 -p 1173:1173 -p 1174:1174 -p 1175:1175 -p 1176:1176 -p 1177:1177 -p 1178:1178 -p 1179:1179 -p 1180:1180 -p 1181:1181 -p 1182:1182 -p 1183:1183 -p 1184:1184 -p 1185:1185 -p 1186:1186 -p 1187:1187 -p 1188:1188 -p 1189:1189 -p 1190:1190 -p 1191:1191 -p 1192:1192 -p 1193:1193 -p 1194:1194 -p 1195:1195 -p 1196:1196 -p 1197:1197 -p 1198:1198 -p 1199:1199 -p 1200:1200 -p 1201:1201 -p 1202:1202 -p 1203:1203 -p 1204:1204 -p 1205:1205 -p 1206:1206 -p 1207:1207 -p 1208:1208 -p 1209:1209 -p 1210:1210 -p 1211:1211 -p 1212:1212 -p 1213:1213 -p 1214:1214 -p 1215:1215 -p 1216:1216 -p 1217:1217 -p 1218:1218 -p 1219:1219 -p 1220:1220 -p 1221:1221 -p 1222:1222 -p 1223:1223 -p 1224:1224 -p 1225:1225 -p 1226:1226 -p 1227:1227 -p 1228:1228 -p 1229:1229 -p 1230:1230 -p 1231:1231 -p 1232:1232 -p 1233:1233 -p 1234:1234 -p 1235:1235 -p 1236:1236 -p 1237:1237 -p 1238:1238 -p 1239:1239 -p 1240:1240 -p 1241:1241 -p 1242:1242 -p 1243:1243 -p 1244:1244 -p 1245:1245 -p 1246:1246 -p 1247:1247 -p 1248:1248 -p 1249:1249 -p 1250:1250 -p 1251:1251 -p 1252:1252 -p 1253:1253 -p 1254:1254 -p 1255:1255 -p 1256:1256 -p 1257:1257 -p 1258:1258 -p 1259:1259 -p 1260:1260 -p 1261:1261 -p 1262:1262 -p 1263:1263 -p 1264:1264 -p 1265:1265 -p 1266:1266 -p 1267:1267 -p 1268:1268 -p 1269:1269 -p 1270:1270 -p 1271:1271 -p 1272:1272 -p 1273:1273 -p 1274:1274 -p 1275:1275 -p 1276:1276 -p 1277:1277 -p 1278:1278 -p 1279:1279 -p 1280:1280 -p 1281:1281 -p 1282:1282 -p 1283:1283 -p 1284:1284 -p 1285:1285 -p 1286:1286 -p 1287:1287 -p 1288:1288 -p 1289:1289 -p 1290:1290 -p 1291:1291 -p 1292:1292 -p 1293:1293 -p 1294:1294 -p 1295:1295 -p 1296:1296 -p 1297:1297 -p 1298:1298 -p 1299:1299 -p 1300:1300 -p 1301:1301 -p 1302:1302 -p 1303:1303 -p 1304:1304 -p 1305:1305 -p 1306:1306 -p 1307:1307 -p 1308:1308 -p 1309:1309 -p 1310:1310 -p 1311:1311 -p 1312:1312 -p 1313:1313 -p 1314:1314 -p 1315:1315 -p 1316:1316 -p 1317:1317 -p 1318:1318 -p 1319:1319 -p 1320:1320 -p 1321:1321 -p 1322:1322 -p 1323:1323 -p 1324:1324 -p 1325:1325 -p 1326:1326 -p 1327:1327 -p 1328:1328 -p 1329:1329 -p 1330:1330 -p 1331:1331 -p 1332:1332 -p 1333:1333 -p 1334:1334 -p 1335:1335 -p 1336:1336 -p 1337:1337 -p 1338:1338 -p 1339:1339 -p 1340:1340 -p 1341:1341 -p 1342:1342 -p 1343:1343 -p 1344:1344 -p 1345:1345 -p 1346:1346 -p 1347:1347 -p 1348:1348 -p 1349:1349 -p 1350:1350 -p 1351:1351 -p 1352:1352 -p 1353:1353 -p 1354:1354 -p 1355:1355 -p 1356:1356 -p 1357:1357 -p 1358:1358 -p 1359:1359 -p 1360:1360 -p 1361:1361 -p 1362:1362 -p 1363:1363 -p 1364:1364 -p 1365:1365 -p 1366:1366 -p 1367:1367 -p 1368:1368 -p 1369:1369 -p 1370:1370 -p 1371:1371 -p 1372:1372 -p 1373:1373 -p 1374:1374 -p 1375:1375 -p 1376:1376 -p 1377:1377 -p 1378:1378 -p 1379:1379 -p 1380:1380 -p 1381:1381 -p 1382:1382 -p 1383:1383 -p 1384:1384 -p 1385:1385 -p 1386:1386 -p 1387:1387 -p 1388:1388 -p 1389:1389 -p 1390:1390 -p 1391:1391 -p 1392:1392 -p 1393:1393 -p 1394:1394 -p 1395:1395 -p 1396:1396 -p 1397:1397 -p 1398:1398 -p 1399:1399 -p 1400:1400 -p 1401:1401 -p 1402:1402 -p 1403:1403 -p 1404:1404 -p 1405:1405 -p 1406:1406 -p 1407:1407 -p 1408:1408 -p 1409:1409 -p 1410:1410 -p 1411:1411 -p 1412:1412 -p 1413:1413 -p 1414:1414 -p 1415:1415 -p 1416:1416 -p 1417:1417 -p 1418:1418 -p 1419:1419 -p 1420:1420 -p 1421:1421 -p 1422:1422 -p 1423:1423 -p 1424:1424 -p 1425:1425 -p 1426:1426 -p 1427:1427 -p 1428:1428 -p 1429:1429 -p 1430:1430 -p 1431:1431 -p 1432:1432 -p 1433:1433 -p 1434:1434 -p 1435:1435 -p 1436:1436 -p 1437:1437 -p 1438:1438 -p 1439:1439 -p 1440:1440 -p 1441:1441 -p 1442:1442 -p 1443:1443 -p 1444:1444 -p 1445:1445 -p 1446:1446 -p 1447:1447 -p 1448:1448 -p 1449:1449 -p 1450:1450 -p 1451:1451 -p 1452:1452 -p 1453:1453 -p 1454:1454 -p 1455:1455 -p 1456:1456 -p 1457:1457 -p 1458:1458 -p 1459:1459 -p 1460:1460 -p 1461:1461 -p 1462:1462 -p 1463:1463 -p 1464:1464 -p 1465:1465 -p 1466:1466 -p 1467:1467 -p 1468:1468 -p 1469:1469 -p 1470:1470 -p 1471:1471 -p 1472:1472 -p 1473:1473 -p 1474:1474 -p 1475:1475 -p 1476:1476 -p 1477:1477 -p 1478:1478 -p 1479:1479 -p 1480:1480 -p 1481:1481 -p 1482:1482 -p 1483:1483 -p 1484:1484 -p 1485:1485 -p 1486:1486 -p 1487:1487 -p 1488:1488 -p 1489:1489 -p 1490:1490 -p 1491:1491 -p 1492:1492 -p 1493:1493 -p 1494:1494 -p 1495:1495 -p 1496:1496 -p 1497:1497 -p 1498:1498 -p 1499:1499 -p 1500:1500 -v ${HOME}/dockervolumes/samba:/var/lib/samba  -e "SAMBA_DOMAIN=samdom" -e "SAMBA_REALM=samdom.example.com" -e "SAMBA_HOST_IP=$(hostname --all-ip-addresses |cut -f 1 -d' ')" --name samdom --dns 127.0.0.1 -d samba-ad-dc
```

The problem is that the port range 1024 and upwards are used for dynamic RPC-calls, luckily Samba goes through them in
order, so the first 500 or so should suffice for testing purposes.

## TODO

* [X] xattr and acl support for docker containers
* [ ] NTP support
* [ ] Backup support (Maybe mount Samba database folders as docker volumes)
* [ ] How to implement redundancy (Samba cluster doesn't seem to be production ready yet)
* [X] Verify that Bind9 Dynamically Loadable Zones (DLZ) work
* [ ] Can this be used for UNIX logins as well?
* [ ] Probably a lot more to make this robust enough for production use
* [ ] Fix random BIND9 startup problems. Failed to connect to /var/lib/samba/private/dns/sam.ldb
