<?php
require '../config.php';
header('Content-Type: application/json');

// Ambil input JSON
$raw = file_get_contents("php://input");
$input = json_decode($raw, true);

// Ambil dari JSON atau fallback dari POST
$username = null;
$password = null;

if (is_array($input)) {
    $username = $input["username"] ?? null;
    $password = $input["password"] ?? null;
}

if ($username === null) $username = $_POST["username"] ?? null;
if ($password === null) $password = $_POST["password"] ?? null;

// Kalau kosong, jangan proses
if (!$username || !$password) {
    echo json_encode([
        "status" => "error",
        "message" => "username dan password wajib diisi"
    ]);
    exit;
}

// Amankan input
$username = mysqli_real_escape_string($conn, $username);

// KUNCI: tetap pakai MD5 seperti kode Anda yang kemarin berhasil
$passwordMd5 = md5($password);

$query = "SELECT * FROM admin_users WHERE username='$username' AND password='$passwordMd5' LIMIT 1";
$result = mysqli_query($conn, $query);

if ($result && mysqli_num_rows($result) == 1) {
    echo json_encode([
        "status" => "success",
        "message" => "Login berhasil"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Username atau password salah"
    ]);
}
?>
