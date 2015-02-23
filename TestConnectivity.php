<?php
/**
 * webserverからdbserverへの接続テスト
 *
 * webserverとdbserver双方が起動している必要がある
 * `$ php TestConnectivity.php`
 */

try {
    // データベースに接続
    $pdo = new PDO(
        'mysql:dbname=test_database;host=192.168.30.11;charset=utf8',
        'webserver',
        'webserver',
        array(
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_EMULATE_PREPARES => false,
        )
    );

    /* データベースから値を取ってきたり、データを挿入したりする処理 */
    $result = $pdo->query('SELECT * FROM test_table');

    var_dump($result->fetchAll());exit;

} catch (Exception $e) {
    // 例外メッセージを後で表示するために変数にセット
    $error = $e->getMessage();
}

