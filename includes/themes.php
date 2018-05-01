<?php
/**
*
*
*/
function DisplayThemeConfig(){

  $cselected = '';
  $hselected = '';
  $tselected = '';

  switch( $_COOKIE['theme'] ) {
    case "custom.css":
      $cselected = "selected";
      break;
    case "hackernews.css":
      $hselected = "selected";
      break;
    case "terminal.css":
      $tselected = "selected";
      break;
    case "business-casual.css":
      $bselected = "selected";
      break;
    case "one-page-wonder.css":
      $oselected = "selected";
      break;
    case "sb-admin-2.css":
      $aselected = "selected";
      break;
    case "timeline.css":
      $tlselected = "selected";
      break;
  }

  ?>
  <div class="row">
  <div class="col-lg-12">
  <div class="panel panel-primary">
  <div class="panel-heading"><i class="fa fa-wrench fa-fw"></i> Change Theme</div>
  <div class="panel-body">
    <div class="row">
    <div class="col-md-6">
    <div class="panel panel-default">
    <div class="panel-body">
      <h4>Theme settings</h4>

  <div class="row">
          <div class="form-group col-md-6">
            <label for="code">Select a theme</label>  
              <select class="form-control" id="theme-select">Select a Theme
                <option value="default" class="theme-link" <?php echo $cselected; ?>>PiHelmetCam (default)</option>
                <option value="hackernews" class="theme-link"<?php echo $hselected; ?>>HackerNews</option>
                <option value="terminal" class="theme-link" <?php echo $tselected; ?>>Terminal</option>
                <option value="business" class="theme-link" <?php echo $bselected; ?>>Business casual</option>
                <option value="opw" class="theme-link" <?php echo $oselected; ?>>One page wonder</option>
                <option value="admin" class="theme-link" <?php echo $aselected; ?>>Start Bootstrap Admin 2</option>
                <option value="timeline" class="theme-link" <?php echo $tlselected; ?>>Timeline</option>
              </select>
          </div>
        </div>

    </div><!-- /.panel-body -->
    </div><!-- /.panel-default -->
    </div><!-- /.col-md-6 -->
    </div><!-- /.row -->

    <form action="?page=system_info" method="POST">
      <input type="button" class="btn btn-outline btn-primary" value="Refresh" onclick="document.location.reload(true)" />
    </form>

  </div><!-- /.panel-body -->
  </div><!-- /.panel-primary -->
  </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->
  <?php
}
?>

