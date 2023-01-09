<?php
class Database {    
    public function dbConnect() {        
        static $DBH = null;      
        if (is_null($DBH)) {              
			$connection = mysqli_init();
            mysqli_ssl_set($connection,NULL,NULL, "terraform-azure/BaltimoreCyberTrustRoot.crt.pem", NULL, NULL);
             mysqli_real_connect($connection, "mav-server.mysql.database.azure.com", "mysqladmin@mav-server", "Bambam12", "helpdesk_system", 3306);		
			if($connection->connect_error){
				die("Error failed to connect to MySQL: " . $connection->connect_error);
			} else {
				$DBH = $connection;
			}         
        }
        return $DBH;    
    }     
}