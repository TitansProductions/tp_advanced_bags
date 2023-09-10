var type = "normal";
var disabled = false;
var disabledFunction = null;
var canClickButton   = true;

var slots = [null, null, null, null, null, null, null];
var emptyHtml = '<p style="text-align:center;vertical-align: middle; color: gray; text-shadow: 0 0 5px rgb(143, 0, 0); opacity: 0.2; line-height: 120px;"></p>';
var slotsHtml = [emptyHtml, emptyHtml, emptyHtml, emptyHtml, emptyHtml];

var selectedSource = 0;

function getItemIMG(item){
    return 'url(nui://tp-base/html/img/items/' + item + '.png)';
}

function closeInventory() {
    $.post("http://tp-advancedbags/closeNUI", JSON.stringify({}));
	$('#playerInventory').html('');
	$('#secondInventory').html('');
}

$(function() {
	window.addEventListener('message', function(event) {
		if (event.data.type == "enable_inventory_otherInventory") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("showloading").style.display="none";

			document.getElementById("otherinventory_inventory").style.display="block";

			disabled = false;
			canClickButton = true;

		}else if (event.data.type == "enable_loading") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("otherinventory_inventory").style.display="none";

			document.getElementById("showloading").style.display="block";

			canClickButton = false;
			
        }else if (event.data.action == "setBagCurrentWeight") {

			document.getElementById("otherPlayerInventoryHeader").innerHTML = "Bag Weight: " + event.data.weight + " / " + event.data.maxWeight + " (" + Math.floor((event.data.weight/event.data.maxWeight * 100)) + "%)";

		}else if (event.data.action == "nodrag") {
            $('.item').draggable("disable");
			$('.otherItem').draggable("disable");

		} else if (event.data.action == "setOtherInventoryItems") {
			otherInventorySetup(event.data.itemList);

            $('.otherItem').draggable({
                helper: 'clone',
                appendTo: 'body',
                zIndex: 99999,
                revert: 'invalid',
                start: function (event, ui) {
                    if (disabled) {
                        return false;
                    }
    
                    $(this).css('background-image', 'none');
                    itemData = $(this).data("otherItem");
                    itemInventory = $(this).data("inventory");
    
                },
                stop: function () {
                    itemData = $(this).data("otherItem");
    
                    if (itemData !== undefined && itemData.name !== undefined) {
 
                        $(this).css('background-image', getItemIMG(itemData.name));
                    }
                }
            });

        }else if (event.data.action == "setItems") {

			inventorySetup(event.data.itemList);

            $('.item').draggable({
                helper: 'clone',
                appendTo: 'body',
                zIndex: 99999,
                revert: 'invalid',
                start: function (event, ui) {
                    if (disabled) {
                        return false;
                    }
    
                    $(this).css('background-image', 'none');
                    itemData = $(this).data("item");
                    itemInventory = $(this).data("inventory");
    
                },
                stop: function () {
                    itemData = $(this).data("item");
    
                    if (itemData !== undefined && itemData.name !== undefined) {
 
                        $(this).css('background-image', getItemIMG(itemData.name));
                    }
                }
            });

		}

	});

});

function Interval(time) {
    var timer = false;
    this.start = function () {
        if (this.isRunning()) {
            clearInterval(timer);
            timer = false;
        }

        timer = setInterval(function () {
            disabled = false;
        }, time);
    };
    this.stop = function () {
        clearInterval(timer);
        timer = false;
    };
    this.isRunning = function () {
        return timer !== false;
    };
}


function disableInventory(ms) {
    disabled = true;

    if (disabledFunction === null) {
        disabledFunction = new Interval(ms);
        disabledFunction.start();
    } else {
        if (disabledFunction.isRunning()) {
            disabledFunction.stop();
        }

        disabledFunction.start();
    }
}

function setCount(item, otherInventory) {
    count = item.count

    if (otherInventory) {
        if (item.limit > 0) {
            count = item.count
        }
    }else{
        if (item.limit > 0) {
            count = item.count + " / " + item.limit
        }
    }

    if (!otherInventory && item.type === "item_weapon") {
        if (count == 0) {
            count = "";
        } else {
            count = '<img src="img/items/bullet.png" class="ammoIcon"> ' + item.count;
        }
    }

    if (item.type === "item_account" || item.type === "item_money") {
        count = "💲" + formatMoney(item.count);
    }

    return count;
}

function inventorySetup(items) {
    $("#playerInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);
		
        if (item.type != "item_weapon" && item.type != "item_account"){
            $("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: ' + getItemIMG(item.name) + '">' +
            '<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
        }else if (item.type == "item_weapon" && item.type != "item_account"){
			$("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: ' + getItemIMG(item.name) + '">'+ '<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
		}else{
            $("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: ' + getItemIMG(item.name) + '">' +
            '<div class="item-count">' + count + '</div>' + ' <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
        }
		
        $('#item-' + index).data('item', item);
        $('#item-' + index).data('inventory', "main");
    });


}
function otherInventorySetup(items) {
    $("#otherPlayerInventory").html("");

    $.each(items, function (index, item) {
        count = setCount(item, true);
		
        if (item.type != "item_weapon" && item.type != "item_account"){
            $("#otherPlayerInventory").append('<div class="otherSlot"><div id="otherItem-' + index + '" class="otherItem" style = "background-image: ' + getItemIMG(item.name) + '">' +
            '<div class="otherItem-count">' + count + '</div> <div class="otherItem-name">' + item.label + '</div> </div ><div class="otherItem-name-bg"></div></div>');
        }else if (item.type == "item_weapon" && item.type != "item_account"){
			$("#otherPlayerInventory").append('<div class="otherSlot"><div id="otherItem-' + index + '" class="otherItem" style = "background-image: ' + getItemIMG(item.name) + '">' + '<div class="otherItem-count">' + count + '</div> <div class="otherItem-name">' + item.label + '</div> </div ><div class="otherItem-name-bg"></div></div>');
		}else{
            $("#otherPlayerInventory").append('<div class="otherSlot"><div id="otherItem-' + index + '" class="otherItem" style = "background-image: ' + getItemIMG(item.name) + '">' +
            '<div class="otherItem-count">' + count + '</div>' + ' <div class="otherItem-name">' + item.label + '</div> </div ><div class="otherItem-name-bg"></div></div>');
        }
		
        $('#otherItem-' + index).data('otherItem', item);
        $('#otherItem-' + index).data('inventory', "main");
    });
}

function formatMoney(n, c, d, t) {
    var c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;

    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t);
};

$(document).ready(function () {
	$("#count").focus(function () {
        $(this).val("")
    }).blur(function () {
        if ($(this).val() == "") {
            $(this).val("1")
        }
    });

	$("body").on("keyup", function (key) {
		// use e.which
		if (key.which == 27){
			closeInventory();
		}
	});

    $('#playerInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("otherItem");
            itemInventory = ui.draggable.data("inventory");

            disableInventory(500);
            $.post("http://tp-advancedbags/TakeFromOtherInventory", JSON.stringify({
                item: itemData,
                number: parseInt($("#count").val())
            }));  
        }
    });

    $('#otherPlayerInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            disableInventory(500);
            $.post("http://tp-advancedbags/TakeFromInventory", JSON.stringify({
                item: itemData,
                number: parseInt($("#count").val())
            }));
        }
    });


    $("#count").on("keypress keyup blur", function (event) {
        $(this).val($(this).val().replace(/[^\d].+/, ""));
        if ((event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    });
});

$.widget('ui.dialog', $.ui.dialog, {
    options: {
        // Determine if clicking outside the dialog shall close it
        clickOutside: false,
        // Element (id or class) that triggers the dialog opening 
        clickOutsideTrigger: ''
    },
    open: function () {
        var clickOutsideTriggerEl = $(this.options.clickOutsideTrigger),
            that = this;
        if (this.options.clickOutside) {
            // Add document wide click handler for the current dialog namespace
            $(document).on('click.ui.dialogClickOutside' + that.eventNamespace, function (event) {
                var $target = $(event.target);
                if ($target.closest($(clickOutsideTriggerEl)).length === 0 &&
                    $target.closest($(that.uiDialog)).length === 0) {
                    that.close();
                }
            });
        }
        // Invoke parent open method
        this._super();
    },
    close: function () {
        // Remove document wide click handler for the current dialog
        $(document).off('click.ui.dialogClickOutside' + this.eventNamespace);
        // Invoke parent close method 
        this._super();
    },
});