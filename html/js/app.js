var money
var transactions

$('#container').hide()
$('#deposit').hide()
$('#withdraw').hide()
$('#transfer').hide()
$('#transactions').hide()

var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
  return new bootstrap.Tooltip(tooltipTriggerEl)
})

window.addEventListener('message', function(event) {
    let item = event.data

    if (item.type == 'UI') {
        if (item.show == true) {
            money = NumberWithCommas(item.playerMoney)
            $('.money').text('$' + money)
            $('#container').fadeIn()
        } else {
            $('#container').hide()
        }
    }

    if (item.type == 'fetchTransactions') {
        transactions = item.playerTransactions

        ShowTransactions()
    }

    if (item.type == 'refresh') {
        money = NumberWithCommas(item.playerMoney)
        $('.money').text('$' + money)
    }
})

$(document).on('click', '.btn-close', function() {
    HideUI()
})

// Main menu buttons
$(document).on('click', '.btn-primary', function() {
    if ($(this).hasClass('btn-deposit')) {
        $('#main').fadeOut()
        $('#deposit').fadeIn()
    } else if ($(this).hasClass('btn-withdraw')) {
        $('#main').fadeOut()
        $('#withdraw').fadeIn()
    } else if ($(this).hasClass('btn-transfer')) {
        $('#main').fadeOut()
        $('#transfer').fadeIn()
    }
})

// Exit buttons
$(document).on('click', '.btn-danger', function() {
    if ($(this).hasClass('btn-deposit-cancel')) {
        $('#deposit').fadeOut()
        $('#main').fadeIn()
    } else if ($(this).hasClass('btn-withdraw-cancel')) {
        $('#withdraw').fadeOut()
        $('#main').fadeIn()
    } else if ($(this).hasClass('btn-transfer-cancel')) {
        $('#transfer').fadeOut()
        $('#main').fadeIn()
    }
})

// Submit buttons
$(document).on('click', '.btn-success', function() {
    if ($(this).hasClass('btn-deposit-submit')) {
        let depositAmount = $('.deposit-amount').val()
        let depositComment = $('.deposit-comment').val()
        if (isNaN(depositAmount) || depositAmount == '' || depositAmount == 0) {
            // value is not a number, isn't set, or equals to 0
        } else {
            // value is a number
            $('#deposit').fadeOut()
            $('#main').fadeIn()
            $('.deposit-amount').val('')
            $('.deposit-comment').val('')
            $.post('https://luke_atm/luke_atm:Deposit', JSON.stringify({
                amount: depositAmount,
                comment: depositComment,
                type: 'deposit'
            }))
        }
    } else if ($(this).hasClass('btn-withdraw-submit')) {
        let withdrawAmount = $('.withdraw-amount').val()
        let withdrawComment = $('.withdraw-comment').val()

        if (isNaN(withdrawAmount) || withdrawAmount == '' || withdrawAmount == 0) {

        } else {
            $('#withdraw').fadeOut()
            $('#main').fadeIn()
            $('.withdraw-amount').val('')
            $('.withdraw-comment').val('')
            $.post('https://luke_atm/luke_atm:Withdraw', JSON.stringify({
                amount: withdrawAmount,
                comment: withdrawComment,
                type: 'withdraw'
            }))
        }
    } else if($(this).hasClass('btn-transfer-submit')) {
        let playerId = $('.transfer-id').val()
        let transferAmount = $('.transfer-amount').val()
        let transferComment = $('.transfer-comment').val()

        if (isNaN(playerId) || playerId == '' || isNaN(transferAmount) || transferAmount == '' || transferAmount == 0) {

        } else {
            $('#transfer').fadeOut()
            $('#main').fadeIn()
            $('.transfer-id').val('')
            $('.transfer-amount').val('')
            $('.transfer-comment').val('')
            $.post('https://luke_atm/luke_atm:TransferMoney', JSON.stringify({
                id: playerId,
                comment: transferComment,
                amount: transferAmount
            }))
        }
    }
})

$(document).on('click', '.nav-btn', function() {
    if ($(this).hasClass('nav-main-btn')) {
        $('#transactions').hide()
        $('#main').show()
        $('.transaction').remove()
    } else if ($(this).hasClass('nav-transaction-btn')) {
        // Postoji problem gde kada stisnes ovo par puta onda stackuje tranzakcije
        $('.transaction').remove()
        $('#main').hide()
        $('#transactions').show()
        $.post('https://luke_atm/luke_atm:OpenTransactions')
    }
})
 

function ShowTransactions() {
    var i;

    for (i = 0; i < transactions.length; i++) {
        var amount = NumberWithCommas(transactions[i].amount)

        if (transactions[i].comment == undefined) {
            transactions[i].comment = ''
        }
        if (transactions[i].transactionType == 'withdraw') {
            $('.transactions-list').append(
                '<div class="transaction-withdraw transaction">' +
                    '<i class="fas fa-wallet"></i>' +
                    '<div class="transaction-amount">' + '-$' + amount +  '</div>' +
                    '<div class="transaction-comment">' + transactions[i].comment +  '</div>' +
                '</div>')
        } else if (transactions[i].transactionType == 'deposit') {
            $('.transactions-list').append(
                '<div class="transaction-withdraw transaction">' +
                    '<i class="fas fa-donate"></i>' +
                    '<div class="transaction-amount">' + '+$' + amount +  '</div>' +
                    '<div class="transaction-comment">' + transactions[i].comment +  '</div>' +
                '</div>')
        } else if (transactions[i].transactionType == 'transfer') {
            let playerId = transactions[i].pid
            let recipient = transactions[i].recipient

            if (playerId == recipient) {
                $('.transactions-list').append(
                    '<div class="transaction-withdraw transaction">' +
                        '<i class="fas fa-exchange-alt"></i>' +
                        '<div class="transaction-amount">' + '+$' + amount +  '</div>' +
                        '<div class="transaction-comment">' + transactions[i].comment +  '</div>' +
                    '</div>')
            } else {
                $('.transactions-list').append(
                    '<div class="transaction-withdraw transaction">' +
                        '<i class="fas fa-exchange-alt"></i>' +
                        '<div class="transaction-amount">' + '-$' + amount +  '</div>' +
                        '<div class="transaction-comment">' + transactions[i].comment +  '</div>' +
                    '</div>')
            }
            
        }
    }
}

function HideUI() {
    $('#container').hide()
    $('#deposit').hide()
    $('#withdraw').hide()
    $('#transfer').hide()
    $('#main').show()
    $('.transaction').remove()
    $.post('https://luke_atm/luke_atm:CloseATM')
}

function NumberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}