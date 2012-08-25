#!/bin/bash

cat << EOS1
Content-Type: text/html

<html><head><title>302 Access Denied</title></head>
<body>
<br/>
<table border="0">
<tr>
  <td>Browser</td>
  <td>${HTTP_USER_AGENT}</td>
</tr>
<tr>
  <td>From</td>
  <td>
EOS1

echo "${QUERY_STRING}<br/>" | \
  sed s/"\?\|\+\|\&"/"<br\/>"/g | \
  sed s/^/"\t"/g

cat << EOS2
  </td>
</tr>
</table>
<br/>
</body>
</html>
EOS2

