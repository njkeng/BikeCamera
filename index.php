<?php

/**
 * Raspberry Pi Helmet Camera
 *
 * For a quick run through, the packages required for the WebGUI are:
 * lighttpd (I have version 1.4.31-2 installed via apt)
 * php5-cgi (I have version 5.4.4-12 installed via apt)
 * along with their supporting packages, php5 will also need to be enabled.
 * 
 * @author     Nathan Kotzur
 * @license    GNU General Public License, version 3 (GPL-3.0)
 * @version    1.0
 * @link       https://github.com/njkeng/PiHelmetCam
 * @see        https://instructables.com
 */

include_once( 'includes/config.php' );
include_once( RASPI_CONFIG.'/pihelmetcam.php' );
include_once( 'includes/functions.php' );
include_once( 'includes/authenticate.php' );
include_once( 'includes/admin.php' );
include_once( 'includes/dhcp.php' );
include_once( 'includes/hostapd.php' );
include_once( 'includes/system.php' );
include_once( 'includes/configure_client.php' );
include_once( 'includes/networking.php' );
include_once( 'includes/themes.php' );
include_once( 'includes/video_settings.php' );
include_once( 'includes/time.php' );
include_once( 'includes/video_files.php' );

# Enable PHP error reporting.  TURN THIS ON FOR DEVELOPMENT, OFF FOR PRODUCTION
#error_reporting(E_ALL);
#ini_set('display_errors', true);

$output = $return = 0;

if(isset($_GET['page'])) {
    $page = $_GET['page'];
} else {
    $page = "";
}

session_start();
if (empty($_SESSION['csrf_token'])) {
    if (function_exists('mcrypt_create_iv')) {
        $_SESSION['csrf_token'] = bin2hex(mcrypt_create_iv(32, MCRYPT_DEV_URANDOM));
    } else {
        $_SESSION['csrf_token'] = bin2hex(openssl_random_pseudo_bytes(32));
    }
}
$csrf_token = $_SESSION['csrf_token'];

# Check if any video file checkboxes have been selected
if(isset($_POST['completed_file'])){
  # Create a zip file containing the selected completed video files
  $completed_zip = '/var/www/html/completed_files.zip';
  if ( ! create_zip($_POST['completed_file'],$completed_zip)) {
    die ("Can't create ".$completed_zip." file");
  } else {
    header('Content-type: application/zip');
    header('Content-Disposition: attachment; filename="'.basename($completed_zip).'"');
    header("Content-length: " . filesize($completed_zip));
    header("Pragma: no-cache");
    header("Expires: 0");
    ob_clean();
    flush();
    readfile($completed_zip);
    unlink($completed_zip);
    exit;
  }
}

?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>
    <?php echo RASPI_PAGETITLE_NAME; ?>
    </title>

    <!-- Bootstrap Core CSS -->
    <link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- MetisMenu CSS -->
    <link href="vendor/metisMenu/metisMenu.min.css" rel="stylesheet">

    <!-- Timeline CSS -->
    <link href="dist/css/timeline.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="dist/css/sb-admin-2.min.css" rel="stylesheet">

    <!-- Morris Charts CSS -->
    <link href="vendor/morrisjs/morris.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

    <!-- Custom CSS -->
    <link href="dist/css/custom.css" title="main" rel="stylesheet">

    <link rel="shortcut icon" type="image/png" href="../img/favicon.png">
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>

    <div id="wrapper">
      <!-- Navigation -->
      <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="index.php"><?php echo RASPI_NAVBAR_NAME; ?></a>
        </div>
        <!-- /.navbar-header -->

        <!-- Navigation -->
        <div class="navbar-default sidebar" role="navigation">
          <div class="sidebar-nav navbar-collapse">
            <ul class="nav" id="side-menu">
              <?php if ( RASPI_VIDEOSETTINGS_ENABLED ) : ?>
              <li>
                <a href="index.php?page=videosettings_conf"><i class="fa fa-video-camera fa-fw"></i> Video settings</a>
              </li>
              <?php endif; ?>
              <?php if ( RASPI_VIDEOFILES_ENABLED ) : ?>
              <li>
                <a href="index.php?page=video_files_conf"><i class="fa fa-file-movie-o fa-fw"></i> Manage video files</a>
              </li>
              <?php endif; ?>              
              <?php if ( RASPI_CLIENT_ENABLED ) : ?>
              <li>
                <a href="index.php?page=wpa_conf"><i class="fa fa-signal fa-fw"></i> Configure WiFi Client</a>
              </li>
              <?php endif; ?>
              <?php if ( RASPI_HOTSPOT_ENABLED ) : ?>
              <li>
                <a href="index.php?page=hostapd_conf"><i class="fa fa-dot-circle-o fa-fw"></i> Configure Hotspot</a>
              </li>
              <?php endif; ?>
              <?php if ( RASPI_NETWORK_ENABLED ) : ?>
              <li>
                <a href="index.php?page=network_conf"><i class="fa fa-sitemap fa-fw"></i> Configure Networking</a>
              </li> 
              <?php endif; ?>
              <?php if ( RASPI_DHCP_ENABLED ) : ?>
              <li>
                <a href="index.php?page=dhcpd_conf"><i class="fa fa-exchange fa-fw"></i> Configure DHCP Server</a>
              </li>
              <?php endif; ?>
              <?php if ( RASPI_TIME_ENABLED ) : ?>
              <li>
                <a href="index.php?page=time_conf"><i class="fa fa-clock-o fa-fw"></i> Time and date</a>
              </li>
              <?php endif; ?>
              <?php if ( RASPI_CONFAUTH_ENABLED ) : ?>
              <li>
                <a href="index.php?page=auth_conf"><i class="fa fa-lock fa-fw"></i> Configure Auth</a>
              </li>
              <?php endif; ?>
              <?php if ( RASPI_SYSTEM_ENABLED ) : ?>
              <li>
                 <a href="index.php?page=system_info"><i class="fa fa-cube fa-fw"></i> System</a>
              </li>
              <?php endif; ?>
            </ul>
          </div><!-- /.navbar-collapse -->
        </div><!-- /.navbar-default -->
      </nav>

      <div id="page-wrapper">

        <!-- Page Heading -->
        <div class="row">
          <div class="col-lg-12">
              <h1 class="page-header">
                <img class="logo" src="img/BikeCamera_logo_simple.png" width="45" height="45">  BikeCamera
              </h1>
          </div>
        </div><!-- /.row -->

        <?php 
        // handle page actions
        switch( $page ) {
          case "videosettings_conf":
            DisplayVideoSettings();
            break;
          case "video_files_conf":
            DisplayVideoFiles();
            break;
          case "dhcpd_conf":
            DisplayDHCPConfig();
            break;
          case "wpa_conf":
            DisplayWPAConfig();
            break;
          case "network_conf":
            DisplayNetworkingConfig();
            break;
          case "hostapd_conf":
            DisplayHostAPDConfig();
            break;
          case "time_conf":
            DisplayTime();
            break;
          case "auth_conf":
            DisplayAuthConfig($config['admin_user'], $config['admin_pass']);
            break;
          case "video_files":
            DisplayVideoFiles();
            break;
          case "system_info":
            DisplaySystem();
            break;
          default:
            DisplayVideoSettings();
        }
        ?>
      </div><!-- /#page-wrapper --> 
    </div><!-- /#wrapper -->

    <!-- PiHelmetCam JavaScript -->
    <script src="dist/js/functions.js"></script>

    <!-- jQuery -->
    <script src="vendor/jquery/jquery.min.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="vendor/bootstrap/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="vendor/metisMenu/metisMenu.min.js"></script>

    <!-- Morris Charts JavaScript -->
    <!--script src="vendor/raphael/raphael-min.js"></script-->
    <!--script src="vendor/morrisjs/morris.min.js"></script-->
    <!--script src="js/morris-data.js"></script-->

    <!-- Custom Theme JavaScript -->
    <script src="dist/js/sb-admin-2.js"></script>

    <!-- Custom PiHelmetCam JS -->
    <script src="js/custom.js"></script>
  </body>
</html>
