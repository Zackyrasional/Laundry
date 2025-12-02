<?php
require '../config.php';

$input = json_decode(file_get_contents("php://input"), true);

$email    = trim($input["email"]);
$password = trim($input["password"]);
$passHash = md5($password);

$q = "SELECT id, name, email, phone, address
      FROM users
      WHERE email='$email' AND password='$passHash'
      LIMIT 1";

$res = mysqli_query($conn, $q);

if (mysqli_num_rows($res) == 1) {
    $row = mysqli_fetch_assoc($res);
    echo json_encode([
        "status"  => "success",
        "message" => "Login berhasil",
        "user"    => $row
    ]);
} else {
    echo json_encode([
        "status"  => "error",
        "message" => "Email atau password salah"
    ]);
}
?>
