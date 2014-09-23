define check_mk::host (
  $target,
  $host_tags = [],
  $use_ip_to_connect = false,
) {
  $host = $title

  if is_array($host_tags) {
    if size($host_tags) > 0 {
      $taglist = join($host_tags,'|')
      $entry = "${host}|${taglist}"
    }
    else {
      $entry = $host
    }    
  }
  elsif $host_tags {
    $entry = "${host}|${host_tags}"
  } 
  else {
    $entry = $host
  }

  concat::fragment { "check_mk-${host}":
    target  => $target,
    content => "  '${entry}',\n",
    order   => 11,
  }

  if $use_ip_to_connect {
    concat::fragment { "check_mk-${host}-ipaddresses":
      target    => $target,
      content   => " \"${host}\" : \"${use_ip_to_connect}\",\n",
      order     => 51,
    }
  }
}
