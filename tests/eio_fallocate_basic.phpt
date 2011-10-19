--TEST--
Check for eio_fallocate function basic behaviour
--SKIPIF--
<?php
if (substr(PHP_OS, 0, 5) != 'Linux') 
	die("skip this test is for Linux platforms only");
?>
--FILE--
<?php 
$old_error_reporting = error_reporting(0);

$temp_filename = "eio-temp-file.tmp";

function my_close_cb($data, $result) {
	global $temp_filename;

	var_dump($result == 0);
	@unlink($temp_filename);
}

function my_falloc_cb($data, $result) {
	var_dump($result == 0);
}

function my_file_opened_callback($data, $result) {
	var_dump($result > 0);
	if ($result > 0) {
		eio_fallocate($result, NULL, 0, 10, EIO_PRI_DEFAULT, "my_falloc_cb", NULL);
		eio_event_loop();

		eio_close($result, EIO_PRI_DEFAULT, "my_close_cb");
		eio_event_loop();
	}
}

eio_open($temp_filename, EIO_O_CREAT | EIO_O_RDWR, NULL, EIO_PRI_DEFAULT, "my_file_opened_callback", NULL);
eio_event_loop();

?>
--CLEAN--
<?php
error_reporting($old_error_reporting);
?>
--EXPECT--
bool(true)
bool(true)
bool(true)