resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.resource_group_location
}

resource "azurerm_virtual_network" "main" {
    name                = "vnet-test"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
    name                 = "subnet-test"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
    name                = "nsg-test"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name                       = "Allow-SSH-From-MyIP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = var.my_public_ip
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Deny-All-Inbound"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

#----------------------------
resource "azurerm_public_ip" "vm_ip_1" {
    name                = "publicip-test-1"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Dynamic"
    sku                 = "Basic"
}

resource "azurerm_network_interface" "vm_nic_1" {
    name                = "nic-test-1"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "ipconfig"
        subnet_id                     = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.vm_ip_1.id
    }
}

resource "azurerm_linux_virtual_machine" "my_vm_1" {
    name                = "vmtest_1"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    size                = "Standard_D2s_v3"
    admin_username      = "azureuser"
    network_interface_ids = [
        azurerm_network_interface.vm_nic_1.id
    ]
    admin_password = "MaKrBaAnMa<31!"

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        name                 = "osdisk_test"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts"
        version   = "latest"
    }

    disable_password_authentication = false
}

#-----------------------------
resource "azurerm_public_ip" "vm_ip_2" {
    name                = "publicip-test-2"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Dynamic"
    sku                 = "Basic"
}

resource "azurerm_network_interface" "vm_nic_2" {
    name                = "nic-test-2"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "ipconfig"
        subnet_id                     = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.vm_ip_2.id
    }
}

resource "azurerm_linux_virtual_machine" "my_vm_2" {
    name                = "vmtest_2"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    size                = "Standard_D2s_v3"
    admin_username      = "azureuser"
    network_interface_ids = [
        azurerm_network_interface.vm_nic_2.id
    ]
    admin_password = "MaKrBaAnMa<32!"

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        name                 = "osdisk_test"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts"
        version   = "latest"
    }

    disable_password_authentication = false
}