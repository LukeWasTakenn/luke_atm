$(document).ready(function() {
    let buttons = ['menuButton1', 'menuButton2', 'menuButton3', 'menuButton4'];
    
    window.addEventListener('message', function(event) {
        if (event.data.type == 'UI') {
            if (event.data.show) {
                let money = GetNumberWithCommas(event.data.playerMoney);
                let bankBalance = $('.bankBalance').text('Bank balance: \n$' + money);
                bankBalance.html(bankBalance.html().replace(/\n/g, '<br/>')); // Adds a new line so that the money appears on a new line
                document.getElementById('container').style.display == 'true';
                $('#container').slideDown();
                $('#transactions-main').hide();
                $('.transaction').remove();
                $('#wrapper-main').show();
            } else if (event.data.show == false) {
                $('#container').hide();
                $('#withdrawBox').hide();
                $('#depositBox').hide();
                $('#transferBox').hide();
                $.post('https://luke_atm/luke_atm:CloseATM', JSON.stringify({}))
            }
        }
        if (event.data.refresh) {
            money = GetNumberWithCommas(event.data.playerMoney);
            bankBalance = $('.bankBalance').text('Bank balance: \n$' + money);
            bankBalance.html(bankBalance.html().replace(/\n/g, '<br/>'));
        }
        if (event.data.type == 'fetchTransactions') {
            let transactions = event.data.playerTransactions;
            transactions.reverse();
            $('#transactions-main').fadeIn();
            for (i = 0; i < transactions.length; i++) {
                if (transactions[i].transactionType == 'withdraw') {
                    $('#transaction-list').append('<li class="withdraw"></li>');
                    $('.withdraw').addClass('transaction');
                } else if (transactions[i].transactionType == 'deposit') {
                    $('#transaction-list').append('<li class="deposit"></li>');
                    $('.deposit').addClass('transaction');
                } else if (transactions[i].transactionType == 'transfer') {
                    $('#transaction-list').append('<li class="transfer"></li>')
                    $('.transfer').addClass('transaction');
                }
            }
            //$('#transaction-list').append('<div class="transfer-amount"></div>');
            $('.withdraw').append('<div class="transaction-withdraw"></div>');
            $('.deposit').append('<div class="transaction-deposit"></div>');
            $('.transfer').append('<div class="transaction-transfer"></div>')
            $('li').each(function(index) {
                $(this).addClass('transfer-amount');
                if (transactions[index].transactionType == 'withdraw') {
                    $(this).append('<div class="transfer-amount">' + 'Amount:' +  '<div class="transfer-amount-div transfer-withdraw">$' + GetNumberWithCommas(transactions[index].amount) + '</div>' + '</div>');
                } else if (transactions[index].transactionType == 'deposit') {
                    $(this).append('<div class="transfer-amount">' + 'Amount:' +  '<div class="transfer-amount-div transfer-deposit">$' + GetNumberWithCommas(transactions[index].amount) + '</div>' + '</div>');
                } else if (transactions[index].transactionType == 'transfer') {
                    $(this).append('<div class="transfer-amount">' + 'Amount:' +  '<div class="transfer-amount-div transfer-transfer">$' + GetNumberWithCommas(transactions[index].amount) + '</div>' + '</div>');
                }
                //$(this).append('<div class="transfer-amount">' + 'Amount:' +  '<div class="transfer-amount-div">$' + GetNumberWithCommas(transactions[index].amount) + '</div>' + '</div>');
                if (typeof(transactions[index].comment) == 'undefined') {
                    transactions[index].comment = '';
                }
                $(this).append('<div class="transfer-comment">' + 'Comment:' + '<div class="transfer-comment-div">' + transactions[index].comment + '</div>' + '</div>');
            });
            
            // Dodati amount u div
        }
    });

    jQuery.each(buttons, function(i, value) {
        $('.' + value).hover(function() {
            $('.' + value).css({'background-color':'white', 'color':'black', 'transition':'0.2s'});
        }, function() {
            $('.' + value).css({'background-color':'rgb(38, 143, 58)', 'color':'white', 'transition':'0.2s'});
        });
    });

    // TRANSFER BUTTON FUNCTIONS //
        $('.menuButton4').click(function() {
            $('#transferBox').fadeIn();
        });

        $('.cancelTransferButton').click(function() {
            $('#transferBox').fadeOut();
            ClearFieldsTransfer();
        });

        $('.submitTransferButton').click(function() {
            let id = $('#idTransfer').val()
            let amount = $('#amountTransfer').val()
            let comment = $('#commentTransferBoxInput').val()
            if (isNaN(id)) {
                $('#idTransfer').css({'border-bottom-color':'rgb(224, 39, 26)'});
                return
            } else if (isNaN(amount)) {
                $('#amountTransfer').css({'border-bottom-color':'rgb(224, 39, 26)'});
            } else {
                if (amount == '' || amount == 0) {
                    $('#amountTransfer').css({'border-bottom-color':'rgb(224, 39, 26)'});
                    return
                } else {
                    $('#idTransfer').css({'border-bottom-color':'rgb(38, 143, 58)'});
                    $('#amountTransfer').css({'border-bottom-color':'rgb(38, 143, 58)'});
                    ClearFieldsTransfer();
                    $('#transferBox').fadeOut();
                    $.post('https://luke_atm/luke_atm:TransferMoney', JSON.stringify({
                        id: id,
                        amount: amount,
                        comment: comment
                    }));
                }
            }
        });

    // //////////////////////// //

    // WITHDRAW BUTTON FUNCTIONS //
    $('.menuButton2').click(function() {
        $('#withdrawBox').fadeIn();
    });

    $('.cancelWithdrawButton').click(function() {
        $('#withdrawBox').fadeOut();
        ClearFieldsWithdraw();
    });

    $('.submitWithdrawButton').click(function() {
        let amount = $('.inputWithdraw').val();
        let withdrawComment = $('#commentWithdrawBoxInput').val();
        if (isNaN(amount) || amount == '' || amount == 0) {
            // If amount is not a number
            $('#amountWithdraw').css({'border-bottom-color':'rgb(224, 39, 26)'});
        } else {
            // If amount is a number
            $('#amountWithdraw').css({'border-bottom-color':'rgb(38, 143, 58)'});
            $('#withdrawBox').fadeOut()
            ClearFieldsWithdraw();
            $.post('https://luke_atm/luke_atm:Withdraw', JSON.stringify({
                withdrawAmount: amount,
                comment: withdrawComment,
                type: 'withdraw'
            }));
        }
    });
    // //////////////////////// //

    // DEPOSIT BUTTON FUNCTIONS //
    $('.menuButton3').click(function() {
        $('#depositBox').fadeIn();
    });

    $('.submitDepositButton').click(function() {
        let moneyDeposit = $('#amountDeposit').val();
        let depositComment = $('#commentDepositBoxInput').val();
        if (isNaN(moneyDeposit) || moneyDeposit == '' || moneyDeposit == 0) {
            // If amount is not a number
            $('#amountDeposit').css({'border-bottom-color':'rgb(224, 39, 26)'});
        } else {
            // If amount is a number
            $('#amountDeposit').css({'border-bottom-color':'rgb(38, 143, 58)'});
            $('#depositBox').fadeOut();
            ClearFieldsDeposit();
            $.post('https://luke_atm/luke_atm:Deposit', JSON.stringify({
                depositAmount: moneyDeposit,
                comment: depositComment,
                type: 'deposit'
            }));
        }
    });

    $('.cancelDepositButton').click(function() {
        $('#depositBox').fadeOut();
        ClearFieldsDeposit();
    });
    // //////////////////////// //

    $('.transactionsReturnButton').click(function() {
        $('#transactions-main').fadeOut();
        $('#wrapper-main').fadeIn();
        $('.transaction').remove();
    });

    $('.exitButton').click(function() {
        $('#container').slideUp();
        $('#withdrawBox').hide();
        $('#depositBox').hide();
        $('#transferBox').hide()
        $.post('https://luke_atm/luke_atm:CloseATM', JSON.stringify({}))
    });

    $('.menuButton1').click(function() {
        $('#wrapper-main').hide();
        $.post('https://luke_atm/luke_atm:OpenTransactions', JSON.stringify({}));
    });

    function GetNumberWithCommas(number) {
        return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    function ClearFieldsWithdraw() {
        document.getElementById("amountWithdraw").value = "";
        document.getElementById("commentWithdrawBoxInput").value = "";
    }

    function ClearFieldsDeposit() {
        document.getElementById("amountDeposit").value = "";
        document.getElementById("commentDepositBoxInput").value = "";
    }

    function ClearFieldsTransfer() {
        document.getElementById("idTransfer").value = "";
        document.getElementById("amountTransfer").value = "";
        document.getElementById("commentTransferBoxInput").value = "";
    }
});