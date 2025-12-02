(function () {
	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="dialog {{#isBig}}big{{/isBig}}">' +
			'<div class="head"><span>{{title}}</span></div>' +
				'{{#isDefault}}<input type="text" name="value" id="inputText"/>{{/isDefault}}' +
				'{{#isBig}}<textarea name="value"/>{{/isBig}}' +
				'<button type="button" name="submit">Submit</button>' +
				'<button type="button" name="cancel">Cancel</button>' +
			'</div>' +
		'</div>'
	;

	window.ESX_MENU_DIALOG = {};
	ESX_MENU_DIALOG.ResourceName = 'esx_menu_dialog';
	ESX_MENU_DIALOG.opened = {};
	ESX_MENU_DIALOG.focus = [];
	ESX_MENU_DIALOG.pos = {};

	ESX_MENU_DIALOG.open = function (namespace, name, data) {
		if (typeof ESX_MENU_DIALOG.opened[namespace] == 'undefined') {
			ESX_MENU_DIALOG.opened[namespace] = {};
		}

		if (typeof ESX_MENU_DIALOG.opened[namespace][name] != 'undefined') {
			ESX_MENU_DIALOG.close(namespace, name);
		}

		if (typeof ESX_MENU_DIALOG.pos[namespace] == 'undefined') {
			ESX_MENU_DIALOG.pos[namespace] = {};
		}

		if (typeof data.type == 'undefined') {
			data.type = 'default';
		}

		if (typeof data.align == 'undefined') {
			data.align = 'top-left';
		}

		data._index = ESX_MENU_DIALOG.focus.length;
		data._namespace = namespace;
		data._name = name;

		ESX_MENU_DIALOG.opened[namespace][name] = data;
		ESX_MENU_DIALOG.pos[namespace][name] = 0;

		ESX_MENU_DIALOG.focus.push({
			namespace: namespace,
			name: name
		});

		document.onkeyup = function (key) {
			if (key.which == 27) { // Escape key
				SendMessage(ESX_MENU_DIALOG.ResourceName, 'menu_cancel', data);
			} else if (key.which == 13) { // Enter key
				SendMessage(ESX_MENU_DIALOG.ResourceName, 'menu_submit', data);
			}
		};

		ESX_MENU_DIALOG.render();
	};

	ESX_MENU_DIALOG.close = function (namespace, name) {
		delete ESX_MENU_DIALOG.opened[namespace][name];

		for (let i = 0; i < ESX_MENU_DIALOG.focus.length; i++) {
			if (ESX_MENU_DIALOG.focus[i].namespace == namespace && ESX_MENU_DIALOG.focus[i].name == name) {
				ESX_MENU_DIALOG.focus.splice(i, 1);
				break;
			}
		}

		ESX_MENU_DIALOG.render();
	};

	ESX_MENU_DIALOG.render = function () {
		let menuContainer = $('#menus')[0];
		$(menuContainer).find('button[name="submit"]').unbind('click');
		$(menuContainer).find('button[name="cancel"]').unbind('click');
		$(menuContainer).find('[name="value"]').unbind('input propertychange');
		menuContainer.innerHTML = '';
		$(menuContainer).hide();

		for (let namespace in ESX_MENU_DIALOG.opened) {
			for (let name in ESX_MENU_DIALOG.opened[namespace]) {
				let menuData = ESX_MENU_DIALOG.opened[namespace][name];
				let view = JSON.parse(JSON.stringify(menuData));

				switch (menuData.type) {

					case 'default': {
						view.isDefault = true;
						break;
					}

					case 'big': {
						view.isBig = true;
						break;
					}

					default: break;
				}

				let menu = $(Mustache.render(MenuTpl, view))[0];

				$(menu).css('z-index', 1000 + view._index);

				$(menu).find('button[name="submit"]').click(function () {
					ESX_MENU_DIALOG.submit(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('button[name="cancel"]').click(function () {
					ESX_MENU_DIALOG.cancel(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('[name="value"]').bind('input propertychange', function () {
					this.data.value = $(menu).find('[name="value"]').val();
					ESX_MENU_DIALOG.change(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				if (typeof menuData.value != 'undefined') {
					$(menu).find('[name="value"]').val(menuData.value);
				}

				menuContainer.appendChild(menu);
			}
		}

		$(menuContainer).show();
		$("#inputText").focus();
	};

	ESX_MENU_DIALOG.submit = function (namespace, name, data) {
		SendMessage(ESX_MENU_DIALOG.ResourceName, 'menu_submit', data);
	};

	ESX_MENU_DIALOG.cancel = function (namespace, name, data) {
		SendMessage(ESX_MENU_DIALOG.ResourceName, 'menu_cancel', data);
	};

	ESX_MENU_DIALOG.change = function (namespace, name, data) {
		SendMessage(ESX_MENU_DIALOG.ResourceName, 'menu_change', data);
	};

	ESX_MENU_DIALOG.getFocused = function () {
		return ESX_MENU_DIALOG.focus[ESX_MENU_DIALOG.focus.length - 1];
	};

	window.onDataDialog = (data) => {
		switch (data.action) {

			case 'openDialogMenu': {
				ESX_MENU_DIALOG.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeDialogMenu': {
				ESX_MENU_DIALOG.close(data.namespace, data.name);
				break;
			}
		}
	};

	window.addEventListener("load",function(){
		window.addEventListener('message', (event) => {
			onDataDialog(event.data);
		});
	});

})();
