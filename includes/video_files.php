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
        <div class="panel-heading"><i class="fa file-movie-o fa-fw"></i>Video files</div>
          <div class="panel-body">
            <form role="form" action="?page=video_files_conf" method="POST">
              <!-- Nav tabs -->
              <ul class="nav nav-tabs">
                <li class="active">
                    <a href="#completed" data-toggle="tab">Processed files</a>
                </li>
                <li>
                  <a href="#raw" data-toggle="tab">Raw files</a>
                </li>
              </ul>

              <input type="submit" class="btn btn-outline btn-primary" name="download_zip" value="Download zip of selected video files" />
              <!-- Tab panes -->
              <div class="tab-content">

                <div class="tab-pane fade in active" id="completed">
                  <h4>Processed video files</h4>
                  <?php CSRFToken() ?>
                  <div class="row">
                    <div class="form-group col-md-4">
                      <label for="checkbox">Files</label>
                      <div class="checkbox">
                        <label>
                          <input type="checkbox">                 
                          <?php foreach ($files as &$value) {echo "<a href='".$completed_path.$value."' target='_black' >".$value."</a><br/>";} ?>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="tab-pane fade" id="raw">
                  <h4>Raw video files</h4>
                  <div class="row">
                    <div class="form-group col-md-4">
                      <label for="checkbox">Files</label>
                      <div class="checkbox">
                        <label>
                          <input type="checkbox">                 
                          <?php foreach ($files as &$value) {echo "<a href='".$raw_path.$value."' target='_black' >".$value."</a><br/>";} ?>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>
              </div><!-- /.tab-content  -->
            </form>
        </div><!-- /.panel-body -->
      </div><!-- /.panel-default -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->
<?php 
}

?>
