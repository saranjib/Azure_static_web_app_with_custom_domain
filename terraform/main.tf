
# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-custom-dns-project"
  location = "East US 2"
}

# Azure Public DNS Zone
resource "azurerm_dns_zone" "public_dns" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.rg.name
}

# CNAME Record for www subdomain
resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  record = azurerm_static_web_app.static_web_app.default_host_name
}


resource "azurerm_static_web_app" "static_web_app" {
  name                = "custom-dns-static-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "East US 2"

  sku_tier = "Free"
  sku_size = "Free"
}

# Custom Domain Configuration
resource "azurerm_static_web_app_custom_domain" "static_web_app_custom_domain" {
  static_web_app_id = azurerm_static_web_app.static_web_app.id

  domain_name     = "www.${var.domain_name}"
  validation_type = "cname-delegation"

  depends_on = [
    azurerm_dns_cname_record.www
  ]
}
