declare namespace IFSC {
  interface IFSCDetails {
    IFSC: string;
    BANK: string;
    BANKCODE: string;
    BRANCH: string;
    ADDRESS: string;
    CITY: string;
    CENTRE: string;
    DISTRICT: string;
    STATE: string;
    ISO3166: string;
    CONTACT: string | null;
    MICR: string | null;
    SWIFT: string | null;
    NEFT: boolean;
    RTGS: boolean;
    IMPS: boolean;
    UPI: boolean;
  }

  function validate(code: string): boolean;
  function fetchDetails(code: string): Promise<IFSCDetails>;
  const bank: Readonly<Record<string, string>>;
}

export = IFSC;
