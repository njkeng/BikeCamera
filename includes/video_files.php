<?php

include_once( 'includes/status_messages.php' );

function DisplayVideoFiles($username, $password){
  $status = new StatusMessages();  

  # Read video files
  $base_dir = "/var/www/html/"
  $completed_path = "video/completed/";
  if ( ! $completed_files = scandir($base_dir.$completed_path)) {
    $status->addMessage('Could not read video files from "Completed" directory', 'warning');
  }
  $raw_path = "video/raw/";
  if ( ! $raw_files = scandir($base_dir.$raw_path)) {
    $status->addMessage('Could not read video files from "Raw" directory', 'warning');
  }

?>
  <div class="row">
    <div class="col-lg-12">
      <div class="panel panel-primary">
        <div class="panel-heading"><i class="fa fa-lock fa-fw"></i>Video files</div>
        <div class="panel-body">
          <p><?php $status->showMessages(); ?></p>
          <form role="form" action="?page=auth_conf" method="POST">
            <?php CSRFToken() ?>
            <div class="row">
              <div class="form-group col-md-4">
                <label for="username">Video file listing</label>
                <?php foreach ($files as &$value) {echo "<a href='".$completed_path.$value."' target='_black' >".$value."</a><br/>";} ?>    <?php foreach ($files as &$value) {echo "<a href='".$raw_path.$value."' target='_black' >".$value."</a><br/>";} ?>
              </div>
            </div>
            <div class="row">
              <div class="form-group col-md-4">
                <label for="password">Old password</label>
                <input type="password" class="form-control" name="oldpass"/>
              </div>
            </div>
            <div class="row">
              <div class="form-group col-md-4">
                <label for="password">New password</label>
                <input type="password" class="form-control" name="newpass"/>
              </div>
            </div>
            <div class="row">
              <div class="form-group col-md-4">
                <label for="password">Repeat new password</label>
                <input type="password" class="form-control" name="newpassagain"/>
              </div>
            </div>
            <input type="submit" class="btn btn-outline btn-primary" name="UpdateAdminPassword" value="Save settings" />
          </form>
        </div><!-- /.panel-body -->
      </div><!-- /.panel-default -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->
<?php 
}

?>
