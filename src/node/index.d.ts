declare module 'ifsc' {
  export interface IfscDetails {
    MICR: string;
    BRANCH: string;
    ADDRESS: string;
    STATE: string;
    CONTACT: string;
    UPI: boolean;
    RTGS: boolean;
    CITY: string;
    CENTRE: string;
    DISTRICT: string;
    NEFT: boolean;
    IMPS: boolean;
    SWIFT: string;
    BANK: string;
    BANKCODE: string;
    IFSC: string;
  }

  export function validate(ifscCode: string): boolean;

  export function fetchDetails(ifscCode: string): Promise<IfscDetails>;
}
