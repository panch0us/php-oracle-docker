<?php
// Минимальная проверка подключения
$conn = @oci_connect('username', 'password', 'ip.ip.ip.ip:1521/UPMO');
if ($conn) {
    echo "✅ CONNECTION SUCCESS\n";
    $st = oci_parse($conn, "SELECT 'Hello Oracle' as test FROM DUAL");
    oci_execute($st);
    $row = oci_fetch_array($st, OCI_ASSOC);
    echo "📋 TEST QUERY: " . $row['TEST'] . "\n";
    oci_close($conn);
} else {
    $e = oci_error();
    echo "❌ CONNECTION FAILED: " . $e['message'] . "\n";
}
?>
