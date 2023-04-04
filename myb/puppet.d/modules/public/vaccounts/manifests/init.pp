class vaccounts() {
  $user_list = lookup('accounts::user_list', Hash[String,Hash], 'hash', {})

  $user_list.each |$user,$props| {
    accounts::user { $user: * => $props }
  }

}
