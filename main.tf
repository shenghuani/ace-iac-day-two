# Enable Distributed Cloud Firewall
resource "aviatrix_distributed_firewalling_config" "ace_automation" {
  enable_distributed_firewalling = true
}

# WebGroup for allowed https domains
resource "aviatrix_web_group" "allow_internet_https" {
  name = "allowed-internet-https"
  selector {
    dynamic "match_expressions" {
      for_each = toset(local.allowed_https_domains)

      content {
        snifilter = match_expressions.value
      }
    }
  }
}

# WebGroup for allowed http domains
resource "aviatrix_web_group" "allow_internet_http" {
  name = "allowed-internet-http"
  selector {
    dynamic "match_expressions" {
      for_each = toset(local.allowed_http_domains)

      content {
        snifilter = match_expressions.value
      }
    }
  }
}

# Rfc1918 SmartGroup
resource "aviatrix_smart_group" "rfc1918" {
  name = "rfc1918"
  selector {
    match_expressions {
      cidr = "10.0.0.0/8"
    }
    match_expressions {
      cidr = "172.16.0.0/12"
    }
    match_expressions {
      cidr = "192.168.0.0/16"
    }
  }
}

# Distributed Cloud Firewall rules
resource "aviatrix_distributed_firewalling_policy_list" "ace_automation" {
  policies {
    name     = "allow-internet-http"
    action   = "PERMIT"
    priority = 0
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 80
    }
    src_smart_groups = [
      aviatrix_smart_group.rfc1918.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_http.uuid,
    ]
  }
  policies {
    name     = "allow-internet-https"
    action   = "PERMIT"
    priority = 100
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 443
    }
    src_smart_groups = [
      aviatrix_smart_group.rfc1918.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_https.uuid,
    ]
  }
  policies {
    name     = "allow-rfc1918"
    action   = "PERMIT"
    priority = 200
    protocol = "ANY"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.rfc1918.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.rfc1918.uuid
    ]
  }
  policies {
    name     = "default-deny-all"
    action   = "DENY"
    priority = 2147483646
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
  }
  depends_on = [
    aviatrix_distributed_firewalling_config.ace_automation
  ]
}
