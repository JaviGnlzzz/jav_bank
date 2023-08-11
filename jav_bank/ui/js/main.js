let app = new Vue({
  el: '#app',
  data: {
    open: false,
    open_pin: false,
    open_dialog: false,
    button_on: 0,
    category: 0,
    pin_user: null,
    pin_code : '',

    info: {
      name: 'Sin informacón',
      money: 0,
      bank: 0,
      location: 'Sin informacón',
      users: [],
      transactions: [
        {title : 'No tienes ninguna transacción reciente', other_info : 'Sin datos', amount : '---', date : '---'}
      ]
    },

    nav: [
      { title: 'Inicio', icon: 'fa-duotone fa-house' },
      { title: 'Transacciones', icon: 'fa-duotone fa-money-from-bracket' },
      // { title: 'Facturas', icon: 'fa-duotone fa-file-invoice' },
    ],

    home_buttons: [
      { title: 'Depositar' },
      { title: 'Transferir' },
      { title: 'Retirar' },
      { title: 'Pin' },
    ],

    fast_options: {
      depositAmount: 0,
      transferId: 0,
      transferMessage: '',
      transferAmount: 0,
      withdrawAmount: 0,
      pin: 0,
    },

    dialog_options: [
      {title : 'cuenta bancaria', icon : 'fa-duotone fa-building-columns', value : 'bank'},
      {title : 'efectivo', icon : 'fa-duotone fa-wallet', value : 'money'}
    ]
  },

  methods: {

    showBank: function () {
      this.open = true
      this.post('update')
    },

    updateCategory: function (index) {
      this.category = index
      this.post('update')
    },

    buildBank: function (data) {
      data.forEach(item => {
          this.info.name = item.name
          this.info.bank = item.accounts.bank
          this.info.money = item.accounts.money
          this.info.location = item.title
          this.info.users = item.result_users
          this.info.transactions = item.result_transactions
      });
    },

    deposit: function() {

      this.post('fast_options', {
        type : 'deposit',
        amount : this.fast_options.depositAmount
      })

      this.fast_options.depositAmount = 0
      
      setTimeout(() => {
        this.post('update')
      }, 100)
    },

    transfer: function() {

      this.post('fast_options', {
        type : 'transfer',
        id : this.fast_options.transferId,
        message : this.fast_options.transferMessage,
        amount : this.fast_options.transferAmount
      })

      this.fast_options.transferId = 0
      this.fast_options.transferAmount = 0
      this.fast_options.transferMessage = ''

      setTimeout(() => {
        this.post('update')
      }, 100)
    },

    withdraw: function() {

      this.post('fast_options', {
        type : 'withdraw',
        amount : this.fast_options.withdrawAmount
      })

      this.fast_options.withdrawAmount = 0

      setTimeout(() => {
        this.post('update')
      }, 100)
    },

    updatePin: function() {

      this.post('fast_options', {
        type : 'update_pin',
        amount : this.fast_options.pin
      })

      this.fast_options.pin = 0

      setTimeout(() => {
        this.post('update')
      }, 100)
    },
    
    enterPin: function(){

      if(Number(this.pin_user) === Number(this.pin_code)) {
        $('.button-enter-pin').addClass('success')

        setTimeout(() => {
          $('.button-enter-pin').removeClass('success')

          this.open_pin = false
          this.pin_code = ''

          setTimeout(() => {
            this.post('open_bank')
          }, 250)

        }, 400)

      }else{
        $('.button-enter-pin').addClass('error')

        setTimeout(() => {
          $('.button-enter-pin').removeClass('error')
        }, 800)
      }
    },

    selectDialog: function(value){
      if(value != undefined){
        this.post('bank_dialog', {account : value})
        this.open_dialog = false
      };
    },

    closeBank: function () {
      this.open = false;
      this.open_pin = false;
      this.open_dialog = false;
      this.post('close');
    },

    post: function (url, data, cb) {
      $.post(`https://${GetParentResourceName()}/${url}`, JSON.stringify(data) || JSON.stringify({}), cb || function () {});
    },

  },

  computed: {
    bankClass: function () {
      return {
          'show': this.open,
          'hide': !this.open
      };
    },

    pinClass: function () {
      return {
        'show': this.open_pin,
        'hide': !this.open_pin
      };
    },

    dialogClass: function () {
      return {
        'show': this.open_dialog,
        'hide': !this.open_dialog
      };
    },
  },

  mounted() {
     window.addEventListener('message', (event) => {
        const {action, type, data_info, pin_code} = event.data;

        if (action) {
          if (type == 'show:interfaz:bank') {
            this.showBank();
          };

          if (type == 'update:interfaz:bank') {
            this.buildBank(data_info);
          };

          if(type == 'show:interfaz:pin'){
            this.open_pin = true
            this.pin_user = pin_code
          };

          if(type == 'show:interfaz:bank_dialog'){
            this.open_dialog = true
          };

        };

     });

     document.onkeyup = ({key}) => key === 'Escape' && this.closeBank()
  },
});