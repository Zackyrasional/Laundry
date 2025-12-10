<?php
require '../config.php';

$query = "SELECT r.*, 
                 p.name AS package_name,
                 p.price_per_kg
          FROM reservations r
          JOIN packages p ON r.package_id = p.id
          ORDER BY r.id DESC";

$result = mysqli_query($conn, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode($data);
?>
