import { NativeModules, Platform } from 'react-native';

const RNSumUpWrapper = NativeModules.RNSumUp;

const RNSumUp = {
  apiKey: '',

  paymentOptionAny: (Platform.OS === 'ios') ? RNSumUpWrapper.SMPPaymentOptionAny : null,
  paymentOptionCardReader: (Platform.OS === 'ios') ? RNSumUpWrapper.SMPPaymentOptionCardReader : null,
  paymentOptionMobilePayment: (Platform.OS === 'ios') ? RNSumUpWrapper.SMPPaymentOptionMobilePayment : null,

  SMPCurrencyCodeBGN: RNSumUpWrapper.SMPCurrencyCodeBGN,
  SMPCurrencyCodeBRL: RNSumUpWrapper.SMPCurrencyCodeBRL,
  SMPCurrencyCodeCHF: RNSumUpWrapper.SMPCurrencyCodeCHF,
  SMPCurrencyCodeCLP: (Platform.OS === 'android') ? RNSumUpWrapper.SMPCurrencyCodeCLP : null, // iOS SDK version currently doesn't supports this currency
  SMPCurrencyCodeCZK: RNSumUpWrapper.SMPCurrencyCodeCZK,
  SMPCurrencyCodeDKK: RNSumUpWrapper.SMPCurrencyCodeDKK,
  SMPCurrencyCodeEUR: RNSumUpWrapper.SMPCurrencyCodeEUR,
  SMPCurrencyCodeGBP: RNSumUpWrapper.SMPCurrencyCodeGBP,
  SMPCurrencyCodeHUF: RNSumUpWrapper.SMPCurrencyCodeHUF,
  SMPCurrencyCodeNOK: RNSumUpWrapper.SMPCurrencyCodeNOK,
  SMPCurrencyCodePLN: RNSumUpWrapper.SMPCurrencyCodePLN,
  SMPCurrencyCodeRON: RNSumUpWrapper.SMPCurrencyCodeRON,
  SMPCurrencyCodeSEK: RNSumUpWrapper.SMPCurrencyCodeSEK,
  SMPCurrencyCodeUSD: RNSumUpWrapper.SMPCurrencyCodeUSD,

  setup(key) {
    this.apiKey = key;
    if (Platform.OS === 'ios') {
      RNSumUpWrapper.setup(key);
    }
  },

  authenticate() {
    return (Platform.OS === 'ios') ? RNSumUpWrapper.authenticate() : RNSumUpWrapper.authenticate(this.apiKey);
  },

  authenticateWithToken(token) {
    return (Platform.OS === 'ios') ? RNSumUpWrapper.authenticateWithToken(token) : RNSumUpWrapper.authenticateWithToken(this.apiKey, token);
  },

  logout() {
    return RNSumUpWrapper.logout();
  },

  prepareForCheckout() {
    return RNSumUpWrapper.prepareForCheckout();
  },

  checkout(request, token = null) {
    if (Platform.OS === 'android') {
      if (!token)
        throw new Error('For Android checkouts you need to provide an OAuth2 token. Please, read: https://github.com/sumup/sumup-android-sdk#5-transparent-authentication');

      return this.isLoggedIn().then((result) => {
        if (!result.isLoggedIn) {
          const authWithToken = new Promise(async resolve => {
            await this.authenticateWithToken(token);
            resolve();
          });

          return authWithToken.then(() => RNSumUpWrapper.checkout(request));
        }
        return RNSumUpWrapper.checkout(request);
      });
    }
    return RNSumUpWrapper.checkout(request);
  },

  preferences() {
    return RNSumUpWrapper.preferences();
  },

  isLoggedIn() {
    return RNSumUpWrapper.isLoggedIn();
  }
};

module.exports = RNSumUp;
