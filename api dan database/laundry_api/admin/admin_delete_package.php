<?php
require '../config.php';
header('Content-Type: application/json');

$raw = file_get_contents("php://input");
$input = json_decode($raw, true);

$id = $input["id"] ?? null;
if (!$id) {
  echo json_encode(["status"=>"error","message"=>"Field wajib: id"]);
  exit;
}

$id = (int)$id;

// optional: cegah hapus jika dipakai reservasi
$cek = mysqli_query($conn, "SELECT id FROM reservations WHERE package_id=$id LIMIT 1");
if ($cek && mysqli_num_rows($cek) > 0) {
  echo json_encode(["status"=>"error","message"=>"Paket tidak bisa dihapus karena sudah dipakai di reservasi"]);
  exit;
}

$sql = "DELETE FROM packages WHERE id=$id";
if (mysqli_query($conn, $sql)) {
  echo json_encode(["status"=>"success","message"=>"Paket berhasil dihapus"]);
} else {
  echo json_encode(["status"=>"error","message"=>mysqli_error($conn)]);
}
