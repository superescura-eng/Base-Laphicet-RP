(function(){

	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="menu">' +
			'<table>' +
				'<thead>' +
					'<tr>' +
						'{{#head}}<td>{{content}}</td>{{/head}}' +
					'</tr>' +
				'</thead>'+
				'<tbody>' +
					'{{#rows}}' +
						'<tr>' +
							'{{#cols}}<td>{{{content}}}</td>{{/cols}}' +
						'</tr>' +
					'{{/rows}}' +
				'</tbody>' +
			'</table>' +
		'</div>'
	;

	window.ESX_MENU_LIST       = {};
	ESX_MENU_LIST.ResourceName = 'esx_menu_list';
	ESX_MENU_LIST.opened       = {};
	ESX_MENU_LIST.focus        = [];
	ESX_MENU_LIST.data         = {};

	ESX_MENU_LIST.open = function(namespace, name, data) {

		if (typeof ESX_MENU_LIST.opened[namespace] == 'undefined') {
			ESX_MENU_LIST.opened[namespace] = {};
		}

		if (typeof ESX_MENU_LIST.opened[namespace][name] != 'undefined') {
			ESX_MENU_LIST.close(namespace, name);
		}

		data._namespace = namespace;
		data._name      = name;

		ESX_MENU_LIST.opened[namespace][name] = data;

		ESX_MENU_LIST.focus.push({
			namespace: namespace,
			name     : name
		});
		
		ESX_MENU_LIST.render();
	};

	ESX_MENU_LIST.close = function(namespace, name) {
		delete ESX_MENU_LIST.opened[namespace][name];

		for (let i=0; i<ESX_MENU_LIST.focus.length; i++) {
			if (ESX_MENU_LIST.focus[i].namespace == namespace && ESX_MENU_LIST.focus[i].name == name) {
				ESX_MENU_LIST.focus.splice(i, 1);
				break;
			}
		}

		ESX_MENU_LIST.render();
	};

	ESX_MENU_LIST.render = function() {

		let menuContainer       = document.getElementById('menus');
		let focused             = ESX_MENU_LIST.getFocused();
		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in ESX_MENU_LIST.opened) {
			
			if (typeof ESX_MENU_LIST.data[namespace] == 'undefined') {
				ESX_MENU_LIST.data[namespace] = {};
			}

			for (let name in ESX_MENU_LIST.opened[namespace]) {

				ESX_MENU_LIST.data[namespace][name] = [];

				let menuData = ESX_MENU_LIST.opened[namespace][name];
				let view = {
					_namespace: menuData._namespace,
					_name     : menuData._name,
					head      : [],
					rows      : []
				};

				for (let i=0; i<menuData.head.length; i++) {
					let item = {content: menuData.head[i]};
					view.head.push(item);
				}

				for (let i=0; i<menuData.rows.length; i++) {
					let row  = menuData.rows[i];
					let data = row.data;

					ESX_MENU_LIST.data[namespace][name].push(data);

					view.rows.push({cols: []});

					for (let j=0; j<row.cols.length; j++) {

						let col     = menuData.rows[i].cols[j];
						let regex   = /\{\{(.*?)\|(.*?)\}\}/g;
						let matches = [];
						let match;

						while ((match = regex.exec(col)) != null) {
							matches.push(match);
						}

						for (let k=0; k<matches.length; k++) {
							col = col.replace('{{' + matches[k][1] + '|' + matches[k][2] + '}}', '<button data-id="' + i + '" data-namespace="' + namespace + '" data-name="' + name + '" data-value="' + matches[k][2] +'">' + matches[k][1] + '</button>');
						}

						view.rows[i].cols.push({data: data, content: col});
					}
				}

				let menu = $(Mustache.render(MenuTpl, view));

				menu.find('button[data-namespace][data-name]').click(function() {
					ESX_MENU_LIST.data[$(this).data('namespace')][$(this).data('name')][parseInt($(this).data('id'))].currentRow = parseInt($(this).data('id')) + 1;
					ESX_MENU_LIST.submit($(this).data('namespace'), $(this).data('name'), {
						data : ESX_MENU_LIST.data[$(this).data('namespace')][$(this).data('name')][parseInt($(this).data('id'))],
						value: $(this).data('value')
					});
				});

				menu.hide();

				menuContainer.appendChild(menu[0]);
			}
		}

		if (typeof focused != 'undefined') {
			$('#menu_' + focused.namespace + '_' + focused.name).show();
		}

		$(menuContainer).show();
	};

	ESX_MENU_LIST.submit = function(namespace, name, data){
		$.post('http://' + ESX_MENU_LIST.ResourceName + '/menu_submit', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			data      : data.data,
			value     : data.value
		}));
	};

	ESX_MENU_LIST.cancel = function(namespace, name){
		$.post('http://' + ESX_MENU_LIST.ResourceName + '/menu_cancel', JSON.stringify({
			_namespace: namespace,
			_name     : name
		}));
	};

	ESX_MENU_LIST.getFocused = function(){
		return ESX_MENU_LIST.focus[ESX_MENU_LIST.focus.length - 1];
	};


	window.addEventListener("load",function(){
		window.addEventListener('message', (event) => {
			switch(event.data.action){
				case 'openMenuList' : {
					ESX_MENU_LIST.open(data.namespace, data.name, data.data);
					break;
				}
	
				case 'closeMenuList' : {
					ESX_MENU_LIST.close(data.namespace, data.name);
					break;
				}
			}
		});
	});

	document.onkeyup = function(data) {
		if(data.which == 27) {
			let focused = ESX_MENU_LIST.getFocused();
			if (focused) {
				ESX_MENU_LIST.cancel(focused.namespace, focused.name);
			}
		}
	};

})();