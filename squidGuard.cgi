#!/bin/bash

cat << EOS1
Content-Type: text/html

<html><head><title>302 Access Denied</title></head>
<body>
<br/>
<table border="0">
<tr>
  <td>Status</td>
  <td>302 Access Denied</td>
</tr>
<tr>
  <td>From</td>
  <td>
EOS1

echo "${QUERY_STRING}" | \
  # URI Encode
  nkf -wMQ | tr '=' '%' | \
  # URI Decode
  tr '%' '=' | nkf -WwmQ | \
  sed s/"\="/"\:"/g | sed s/"\&"/"<br\/>"/g
cat << EOS2
  </td>
</tr>
<tr>
  <td>Browser</td>
  <td>${HTTP_USER_AGENT}</td>
</tr>
</table>
<br/>
</body>
</html>
EOS2

