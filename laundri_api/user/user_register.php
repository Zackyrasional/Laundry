<?php
require '../config.php';

$input = json_decode(file_get_contents("php://input"), true);

$name     = trim($input["name"]);
$email    = trim($input["email"]);
$password = trim($input["password"]);
$phone    = trim($input["phone"]);
$address  = trim($input["address"]);

if ($name == "" || $email == "" || $password == "" || $phone == "" || $address == "") {
    echo json_encode([
        "status" => "error",
        "message" => "Semua field wajib diisi"
    ]);
    exit;
}

// cek email sudah dipakai?
$cek = mysqli_query($conn, "SELECT id FROM users WHERE email='$email' LIMIT 1");
if (mysqli_num_rows($cek) > 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Email sudah terdaftar"
    ]);
    exit;
}

$passHash = md5($password);

$q = "INSERT INTO users (name, email, password, phone, address)
      VALUES ('$name', '$email', '$passHash', '$phone', '$address')";

if (mysqli_query($conn, $q)) {
    $id = mysqli_insert_id($conn);
    echo json_encode([
        "status" => "success",
        "message" => "Registrasi berhasil",
        "user" => [
            "id"      => $id,
            "name"    => $name,
            "email"   => $email,
            "phone"   => $phone,
            "address" => $address
        ]
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => mysqli_error($conn)
    ]);
}
?>
