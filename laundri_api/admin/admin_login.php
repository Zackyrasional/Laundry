<?php
require '../config.php';

$input = json_decode(file_get_contents("php://input"), true);

$username = $input["username"];
$password = md5($input["password"]);

$query = "SELECT * FROM admin_users WHERE username='$username' AND password='$password' LIMIT 1";
$result = mysqli_query($conn, $query);

if (mysqli_num_rows($result) == 1) {
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
